#!/bin/bash

function usage {
echo -e "usage: `basename $0` [action] [folder]

positional arguments:
  <action>\tmay be either of
    mkfs\tInitializes an S3QL file system.
    mount\tMount an S3QL file system.
    fsck\tChecks and repairs an S3QL filesystem.
    stat\tPrint file system statistics.
    umount\tUn mount the S3QL file system.
    flush\tFlush file system cache\n"
    exit 0
}

if [ $# -ne 2  ]; then
    usage
fi

folder=$2
base_dir=/cloud
cachedir="${base_dir}/s3ql_cache/${folder}"
storage_url="/root/Cloud Mail.Ru/s3_data/photos/${folder}"
mountpoint="${base_dir}/s3ql_mount/${folder}"
log="${cachedir}/$1.log"
#exportfs_bin=`which exportfs`
chown_bin=`which chown`

case "$1" in

mkfs)
    echo -e "\nInitializing the S3QL file system with parameters\n"
    echo -e "  cachedir - ${cachedir}\n  storage-url - \"${storage_url}\"\n log - ${log}\n"
    mkdir -p ${cachedir} "${storage_url}"
#    ${chown_bin} -R 1000:1000 ${cachedir} "${storage_url}"
    mkfs.s3ql --cachedir ${cachedir} --debug local://"${storage_url}" 2>&1 | tee -a "${base_dir}/mkfs_s3ql.log"
    echo -e "\n${folder}" >> "${base_dir}/s3ql_readme.txt"
    grep "BEGIN MASTER KEY" -A 2 "${base_dir}/mkfs_s3ql.log" >> "${base_dir}/s3ql_readme.txt"
    rm -f "${base_dir}/mkfs_s3ql.log"
    echo "Exit code ===== $? ====="
    ;;
mount)
    echo -e "\nMounting the S3QL file system with parameters\n"
    echo -e "  cachedir - ${cachedir}\n  storage-url - \"${storage_url}\"\n  mountpoint - ${mountpoint}\n  log - ${log}\n"
    mkdir -p ${cachedir} "${storage_url}" ${mountpoint}
    mount.s3ql --cachedir ${cachedir} --debug --log ${log} --allow-other --nfs --cachesize 1024000 --compress none local://"${storage_url}" ${mountpoint}
#    ${chown_bin} -R 1000:1000 ${cachedir} "${storage_url}" ${mountpoint}
    ;;
fsck)
    echo -e "\nChecking and repairing the S3QL filesystem with parameters\n"
    echo -e "  cachedir - ${cachedir}\n  storage-url - \"${storage_url}\"\n  log - ${log}\n"
    mkdir -p ${cachedir} "${storage_url}"
#    ${chown_bin} -R 1000:1000 ${cachedir} "${storage_url}"
    fsck.s3ql --cachedir ${cachedir} --debug --log ${log} local://"${storage_url}"
    echo "Exit code ===== $? ====="

    ;;
stat)
    echo -e "\nPrinting file system statistics. with parameters\n"
    echo -e "  mountpoint - ${mountpoint}\n"
    s3qlstat ${mountpoint}
    echo "Exit code ===== $? ====="

    ;;
flush)
    echo -e "\nFlushing file system cache\n"
    echo -e "  mountpoint - ${mountpoint}\n"
    s3qlctrl --debug flushcache ${mountpoint}
    echo "Exit code ===== $? ====="

    ;;
umount)
    echo -e "\nUn mounting the S3QL file system with parameters\n"
    echo -e "  mountpoint - ${mountpoint}\n"
    mountpoint_=`echo ${mountpoint} | sed 's%/%\\\/%g'`

#    sed "/${mountpoint_}/d" -i /etc/exports && ${exportfs_bin} -r
    umount.s3ql --debug ${mountpoint}
    echo "Exit code ===== $? ====="
    ;;
*) echo "I dont know this action"
    usage
   ;;
esac
