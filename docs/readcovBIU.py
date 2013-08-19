#! /usr/bin/env python

# run as 
# readcovBIU.py Noise.cov > noiseCov.txt
import sys, struct



filename = sys.argv[1] 
cov = open(filename)
# Read the header.
fmt = ">8s1i256s256s1i4d3i4x"
head = cov.read(struct.calcsize(fmt))
l = struct.unpack(fmt, head)
N = l[4] # 248

# Read the indices.
fmt = ">%di" % N
buf = cov.read(struct.calcsize(fmt))
chan_idx = struct.unpack(fmt, buf) # 1,0,7,9...

# Read the covariance matrix.

fmt = ">%dd" % (N * N)
buf = cov.read(struct.calcsize(fmt))
mat = struct.unpack(fmt, buf)

# print N
for i in range(N):
	for j in range(N):
		print mat[i * N + j]
