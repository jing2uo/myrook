#!/bin/bash

part_disk(){
  (
  echo o # Create a new empty DOS partition table
  echo Y 
  echo n # Add a new partition
  echo   # Partition number
  echo   # First sector (Accept default: 1)
  echo 781412183  # Last sector (Accept default: varies)
  echo
  echo n
  echo 
  echo
  echo 1562824334
  echo
  echo w # Write changes
  echo Y
  ) | gdisk $1 &> /dev/null
}

for i in "sdb" "sdd" "sdf"
do
  echo "blkdiscard $i"
  sgdisk -Z /dev/$i
  blkdiscard /dev/$i
  part_disk /dev/$i
  for j in 1 2
  do
    echo "wipefs /dev/$i$j"
    wipefs -a /dev/$i$j
  done
done

rm -rf /var/lib/rook/*
