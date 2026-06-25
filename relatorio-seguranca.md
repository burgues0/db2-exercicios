# Relatório de Backup e Segurança

Obs.: os exemplos mostrados consideram que o servidor de origem tem diversos discos pra armazenar os backups gerados. Além disso, não foi efetuada uma verdadeira integração com uma Cloud externa pois não consegui gerar um s3/algo similar na Azure com o perfil de estudante do CEFET.

## Backup

| Tipo | Frequência | Destinos | Retenção |
|------|-----------|---------|---------|
| Diario | Diariamente 01:00 | Disco local (`/var/backups`) | 30 dias |
| Semanal | Todo Domingo 02:00 | Cloud (S3) + segundo disco (`/mnt/disco2`) | 4 semanas |
| Mensal | 1° dia do mes | Cloud (S3) + segundo disco + HD externo (`/mnt/hd-externo`) | 12 meses |

### Backup diário
**Cronjob**: "0 1 * * * /bin/bash /opt/clinica/backup_diario.sh"

Salvo localmente em `/var/backups/clinica`.

```bash
#!/bin/bash
DATA=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/clinica"
DB_NAME="postgres"
DB_USER="clinica_admin"

mkdir -p "$BACKUP_DIR"

pg_dump -U "$DB_USER" -d "$DB_NAME" -F c -Z 9 -f "$BACKUP_DIR/clinica_${DATA}.dump"

if [ $? -ne 0 ]; then
    echo "[ERRO] falha no backup" >&2
fi

find "$BACKUP_DIR" -name "*.dump" -mtime +30 -delete
```

### Backup semanal
**Cronjob**: "0 2 * * 0 /bin/bash /opt/clinica/backup_semanal.sh"

Enviado para a cloud e copiado para um segundo disco no mesmo servidor.

```bash
#!/bin/bash
DATA=$(date +%Y%m%d)
ARQUIVO="/var/backups/clinica/clinica_${DATA}.dump"
DB_NAME="postgres"
DB_USER="clinica_admin"

pg_dump -U "$DB_USER" -d "$DB_NAME" -F c -Z 9 -f "$ARQUIVO"

if [ $? -eq 0 ]; then
    rclone copy "$ARQUIVO" s3remote:backups/semanal/
    cp "$ARQUIVO" /mnt/disco2/backups/
fi
```

### Backup mensal
**Cronjob**: "0 3 1 * * /bin/bash /opt/clinica/backup_mensal.sh"

Enviado para a cloud, copiado para o segundo disco e para um HD externo.

```bash
#!/bin/bash
DATA=$(date +%Y%m)
ARQUIVO="/var/backups/clinica/clinica_mensal_${DATA}.dump"
DB_NAME="postgres"
DB_USER="clinica_admin"

pg_dump -U "$DB_USER" -d "$DB_NAME" -F c -Z 9 -f "$ARQUIVO"

if [ $? -eq 0 ]; then
    rclone copy "$ARQUIVO" s3remote:backups/mensal/
    cp "$ARQUIVO" /mnt/disco2/backups/mensal/
    cp "$ARQUIVO" /mnt/hd-externo/backups/
fi
```

### Restauração

```bash
pg_restore -U clinica_admin -d postgres -F c /var/backups/clinica/clinica_20260101_010000.dump
```

### Verificação mensal

```bash
createdb clinica_teste
pg_restore -U clinica_admin -d clinica_teste /var/backups/clinica/ultimo.dump
psql -U clinica_admin -d clinica_teste -c "SELECT COUNT(*) FROM consulta;"
psql -U clinica_admin -d clinica_teste -c "SELECT COUNT(*) FROM animal;"
dropdb clinica_teste
```

---

## Segurança

### Controle de Acesso (RBAC)

Quatro roles definidas conforme perfil de acesso, seguindo o princípio do menor privilégio:

| Role | Acesso |
|------|--------|
| `clinica_readonly` | Apenas leitura |
| `clinica_recepcao` | Leitura, agendamento, faturamento |
| `clinica_veterinario` | Leitura, prontuario, exames, vacinas |
| `clinica_admin` | Acesso total |

### Row Level Security

Garante que cada unidade acesse apenas seus próprios dados.

Exemplo na tabela `consulta`:
```
ALTER TABLE consulta ENABLE ROW LEVEL SECURITY;
```

### Auditoria

Coberta pela tabela `log_prontuario` via trigger `trg_log_consulta`.

Para complementar, seria possível adicionar as seguintes linhas ao `postgresql.conf`:

```
log_statement = 'ddl'
log_connections = on
```

---

## Plano de Recuperação

| Cenário | Tempo para recuperar | Perda máxima de dados |
|---------|---------------------|----------------------|
| Exclusão acidental | < 1 hora | Até 24 horas (último backup diário) |
| Corrupção de tabela | < 30 min | Até 24 horas (último backup diário) |
| Falha total do servidor | < 2 horas | Até 24 horas (último backup diário) |
| Perda do servidor e disco local | < 4 horas | Até 1 semana (backup semanal externo) |
