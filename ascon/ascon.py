################################################################
## Author    : Ahmet MALAL
## Project   : ASCON Pyhton Implementation Algorithm 
## Date      : 16.07.2024
################################################################

import numpy as np

## ALGORITHM CONSTANTS ##  
S_TABLE = [4,11,31,20,26,21,9,2,27,5,8,18,29,3,6,28,30,19,7,14,0,13,17,24,16,12,1,25,22,10,15,23]
CONST   = [0xf0,0xe1,0xd2,0xc3,0xb4,0xa5,0x96,0x87,0x78,0x69,0x5a,0x4b,0x3c,0x2d,0x1e,0x0f] 

def rot(value, positions, direction='right'):
    # Ensure the input is a 64-bit integer
    value &= 0xFFFFFFFFFFFFFFFF
    
    if direction == 'left':
        # Perform the circular left rotation
        rotated_value = ((value << positions) & 0xFFFFFFFFFFFFFFFF) | (value >> (64 - positions))
    elif direction == 'right':
        # Perform the circular right rotation
        rotated_value = (value >> positions) | ((value << (64 - positions)) & 0xFFFFFFFFFFFFFFFF)
    else:
        raise ValueError("Direction must be 'left' or 'right'")
    
    return rotated_value

def linear(state):
    state[0] = state[0] ^ rot(state[0],19) ^ rot(state[0],28)
    state[1] = state[1] ^ rot(state[1],61) ^ rot(state[1],39)
    state[2] = state[2] ^ rot(state[2], 1) ^ rot(state[2], 6)
    state[3] = state[3] ^ rot(state[3],10) ^ rot(state[3],17)
    state[4] = state[4] ^ rot(state[4], 7) ^ rot(state[4],41)
    return state

def subs(state):
    
    res = [0,0,0,0,0]

    for i in range(0,64):
        x0 = ((state[0]>>(63-i))&0x1)
        x1 = ((state[1]>>(63-i))&0x1)
        x2 = ((state[2]>>(63-i))&0x1)
        x3 = ((state[3]>>(63-i))&0x1)
        x4 = ((state[4]>>(63-i))&0x1)

        s_in  = (x0<<4) | (x1<<3) | (x2<<2) | (x3<<1) | x4 
        s_out = S_TABLE[s_in]

        res[0] = (((s_out>>4)&0x1)<<(63-i)) | res[0]
        res[1] = (((s_out>>3)&0x1)<<(63-i)) | res[1]
        res[2] = (((s_out>>2)&0x1)<<(63-i)) | res[2]
        res[3] = (((s_out>>1)&0x1)<<(63-i)) | res[3]
        res[4] = (((s_out   )&0x1)<<(63-i)) | res[4]

    return res

def add_const(state, i, a):
    state[2] = state[2] ^ CONST[12-a+i]
    return state

def p(state,a):
    for i in range(0,a):
        state = add_const(state,i,a)
        state = subs(state)
        state = linear(state)
    return state

def init(state,key):
    state = p(state,12)
    state[3] ^= key[0]
    state[4] ^= key[1]
    return state

def associated_data_128(state,len,data):
    for i in range(0,len):
        state[0] = state[0] ^ data[i]
        state = p(state,6)
    state[4] = state[4] ^ 0x01;
    return state

def associated_data_128a(state,len,data):
    for i in range(0,int(len/2)):
        state[0] = state[0] ^ data[2*i]
        state[1] = state[1] ^ data[2*i+1]
        state = p(state,8)
    state[4] = state[4] ^ 0x01;
    return state

def encrypt_128(state,len,plain):
    res = [0]*len
    res[0] = plain[0]^state[0]
    state[0] = res[0]
    for i in range(1,len):
        state = p(state,6)
        res[i] = plain[i]^state[0]
        state[0] = res[i]
    return res,state

def encrypt_128a(state,len,plain):
    res = [0]*len
    res[0] = plain[0]^state[0]
    res[1] = plain[1]^state[1]
    state[0] = res[0]
    state[1] = res[1]

    for i in range(1,int(len/2)):
        state = p(state,8)
        res[2*i] = plain[2*i]^state[0]
        res[2*i+1] = plain[2*i+1]^state[1]
        state[0] = res[2*i]
        state[1] = res[2*i+1]
    return res,state

def finalize_128(state,key):
    state[0]  = state[0]
    state[1] ^= key[0]
    state[2] ^= key[1]
    state[3] ^= 0x0
    state[4] ^= 0x0
    state = p(state,12)
    tag = [state[3]^key[0],state[4]^key[1]]
    return tag

def finalize_128a(state,key):
    state[0]  = state[0]
    state[1]  = state[1]
    state[2] ^= key[0]
    state[3] ^= key[1]
    state[4] ^= 0x0
    state = p(state,12)
    tag = [state[3]^key[0],state[4]^key[1]]
    return tag

def ascon_128a(iv,nonce,key,assoc_data,plain):
    state = [iv,key[0],key[1],nonce[0],nonce[1]]
    state = init(state,key)
    state = associated_data_128a(state,len(assoc_data),assoc_data)
    cipher,state = encrypt_128a(state,len(plain),plain)
    print("cipher: ")
    for i in cipher:
        print(hex(i))
    tag = finalize_128a(state,key)
    print("Tag: ")
    for i in tag:
        print(hex(i))
    return cipher,tag
    
def ascon_128(iv,nonce,key,assoc_data,plain):
    state = [iv,key[0],key[1],nonce[0],nonce[1]]
    state = init(state,key)
    state = associated_data_128(state,len(assoc_data),assoc_data)
    cipher,state = encrypt_128(state,len(plain),plain)
    print("cipher: ")
    for i in cipher:
        print(hex(i))
    tag = finalize_128(state,key)
    print("Tag: ")
    for i in tag:
        print(hex(i))
    return cipher,tag
#---------------------------------------------------

print("---------")
iv          = 0x0
key         = [0x1,0x2]
nonce       = [0x3,0x4]

assoc_data  = [0x0,0x0,0x0,0x1,0x0,0x2,0x0,0x3,0x0,0x4,0x0,0x5]
plain       = [0x0,0x0,0x0,0x1,0x0,0x2,0x0,0x3,0x0,0x4,0x0,0x5]
ascon_128a(iv,nonce,key,assoc_data,plain)
print("---------")
assoc_data  = [0x0,0x1,0x2,0x3,0x4]
plain       = [0x0,0x1,0x2,0x3,0x4]
ascon_128(iv,nonce,key,assoc_data,plain)


 