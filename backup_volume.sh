#!/bin/bash

# Configs 
 VOLUME_NAME="my_volume"
 BACKUP_DATE=$(date +%d_%m_%Y)
 FILE_NAME="backup_bd_${BACKUP_DATE}.tar.gz"
 LOG_FILE="log_backup_${BACKUP_DATE}.txt"
 TMP_DIR="/tmp/backup_pg"
 LOG_DIR_WINDOWS="/mnt/c/Users/Paulo/BackupsDocker"    


 mkdir -p "$TMP_DIR"
 mkdir -p "$LOG_DIR_WINDOWS"

 echo "=== Backup iniciado em $(date) ===" >> "${TMP_DIR}/${LOG_FILE}"        
 echo "Volume: $VOLUME_NAME" >> "${TMP_DIR}/${LOG_FILE}"

 START_TIME=$SECONDS

 # Volume backup
 docker run --rm \
   -v "${VOLUME_NAME}:/volume" \
   -v "${TMP_DIR}:/backup" \
   alpine \
   sh -c "tar czf /backup/${FILE_NAME} -C /volume ." >> "${TMP_DIR}/${LOG_FILE}" 2>&1
 
 if [ $? -eq 0 ]; then
   echo "[OK] Backup criado: ${FILE_NAME}" >> "${TMP_DIR}/${LOG_FILE}"
 else
   echo "[ERRO] Falha ao criar o backup." >> "${TMP_DIR}/${LOG_FILE}"
   exit 1
 fi
 
 # Backup details
 VOLUME_SIZE=$(du -h "${TMP_DIR}/${FILE_NAME}" | cut -f1)
 HASH=$(sha256sum "${TMP_DIR}/${FILE_NAME}" | awk '{print $1}')
 echo "VOLUME_SIZE do backup: $VOLUME_SIZE" >> "${TMP_DIR}/${LOG_FILE}"
 echo "SHA256: $HASH" >> "${TMP_DIR}/${LOG_FILE}"
 
 ELAPSED=$(( SECONDS - START_TIME ))
 echo "Tempo total: ${ELAPSED} segundos">> "${TMP_DIR}/${LOG_FILE}"
 
 cp "${TMP_DIR}/${LOG_FILE}" "${LOG_DIR_WINDOWS}/${LOG_FILE}"
 
 rm -rf "$TMP_DIR"
 
 echo "Backup finalizado com status: $LOG_UPLOAD_STATUS"