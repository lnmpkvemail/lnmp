#!/usr/bin/env python
import os

dir = os.path.dirname(__file__)
disk = os.statvfs(dir)
Avail = disk.f_bavail * disk.f_bsize / (1024*1024*1024)
print(int(Avail))