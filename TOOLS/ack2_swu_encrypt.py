#!/usr/bin/env python3

from Crypto.Cipher import AES
import hashlib
import os
import sys, getopt

def encrypt_aes_cbc(input_file, output_file, first_aes_key, second_aes_key, offset, input_model, input_version):
    try:
        block_size = 16

        output_file_tmp = output_file + ".tmp"

        # Convert hex keys to bytes
        first_aes_key_bytes = bytes.fromhex(first_aes_key)

        # Read IV from the second AES key
        iv = bytes.fromhex(second_aes_key[:32])

        # Create AES cipher objects
        cipher = AES.new(first_aes_key_bytes, AES.MODE_CBC, iv)

        md5_lib = hashlib.md5()
        file_size = os.path.getsize(input_file)
        last_size = file_size % 16
        if last_size == 0:
            file_size_ext = file_size
        else:
            file_size_ext = ((file_size // 16) * 16) + 16
        with open(input_file, 'rb') as file_input:
            with open(output_file_tmp, 'wb') as file_output:
                header=bytearray(b'\x00' * offset)
                header[0]=0x14
                header[1]=0x17
                header[2]=0x0B
                header[3]=0x17
                version=str(input_version).split('.')
                header[4]=int(version[0])
                header[5]=int(version[1])
                header[6]=int(version[2])
                header[12]=file_size_ext % 256
                header[13]=(file_size_ext // 256) % 256
                header[14]=(file_size_ext // 65536) % 256
                header[15]=file_size_ext // 16777216
                if input_model=='K2Plus':
                    header[7]=1
                if input_model=='K2Max':
                    header[7]=2
                file_output.write(header)
                while True:
                    plaintext = file_input.read(block_size)
                    if not plaintext:
                        break
                        
                    if len(plaintext)<block_size:
                        plaintext=bytearray(plaintext)
                        sz=len(plaintext)
                        if plaintext[-1]!=0:
                            plaintext.extend(b'\x00' * (block_size - sz))
                        else:
                            plaintext.extend(b'\x0B' * (block_size - sz))

                    # Encrypt the block
                    ciphertext = cipher.encrypt(plaintext)
                    file_output.write(ciphertext)
                    md5_lib.update(ciphertext)

        file_md5 = md5_lib.digest()

        # insert the body md5 hash in the header
        with open(output_file_tmp, 'rb') as file_input:
            with open(output_file, 'wb') as file_output:
                block = file_input.read(block_size)
                file_output.write(block)
                block = file_input.read(block_size)
                file_output.write(file_md5)
                while True:
                    block = file_input.read(block_size)
                    if not block:
                        break
                    file_output.write(block)
        os.remove(output_file_tmp)
        return True
    except:
        print("Errors found! Canceled.")
        return False

def main(argv):
    input_file_path = ''
    output_file_path = ''
    input_model = ''
    input_version = ''
    try:
        opts, args = getopt.getopt(argv,"hi:o:m:v:",["ifile=","ofile=",'model=','version='])
    except getopt.GetoptError:
        print ('ack2_swu_encrypt.py -i update.zip -o update.bin -m K2Pro -v 3.1.0')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print ('ack2_swu_encrypt.py -i update.zip -o update.bin -m model -v version')
            sys.exit()
        elif opt in ("-i", "--ifile"):
            input_file_path = arg
        elif opt in ("-o", "--ofile"):
            output_file_path = arg
        elif opt in ("-m", "--model"):
            input_model = arg
        elif opt in ("-v", "--version"):
            input_version = arg
    print ('AnyCubic Kobra 2 SWU to BIN Converter V1.0')
    print ('Input  file: ', input_file_path)
    print ('Output file: ', output_file_path)
    print ('Model      : ', input_model)
    print ('Version    : ', input_version)
    first_aes_key_hex = "78B6A614B6B6E361DC84D705B7FDDA33C967DDF2970A689F8156F78EFE0B1FCE"
    second_aes_key_hex = "54E37626B9A699403064111F77858049"
    offset_value = 32  # Provide the offset value if needed
    print ('Processing...')
    if encrypt_aes_cbc(input_file_path, output_file_path, first_aes_key_hex, second_aes_key_hex, offset_value, input_model, input_version):
        print ('Done!')
   
main(sys.argv[1:])

