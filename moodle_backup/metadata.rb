# Backup moodledata to s3

name "moodle_backup"

recipe "moodle_backup", "Backup moodledata to s3"

# s3 bucket must be specified in Opswork stack custom JSON, e.g.,
# {
# 	"backupbucket": "billys-moodle-backups"
# }
