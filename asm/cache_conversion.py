import argparse

def read_and_process_file(input_file_path):
    cache_line=[]
    tb_cache=[]
    processed_words=0
    with open(input_file_path, 'r') as file:
        for word in file:
            cache_line.insert(0,word.replace('\n',''))
            processed_words+=1
            #generate SV TB line
            if(processed_words==4):
                tb_cache.append(f"procesador.cache.cache_memory[{len(tb_cache)}] = 128'h{''.join(cache_line)};")
                cache_line=[]
                processed_words=0
        #scenario if the number of words is not multiple of 4
        if processed_words > 0:
            nop = '00000000'
            instr = (nop*(4-processed_words))+''.join(cache_line)
            tb_cache.append(f"procesador.cache.cache_memory[{len(tb_cache)}] = 128'h{instr};")
    for i in range(8-len(tb_cache)):
        tb_cache.append(f"procesador.cache.cache_memory[{len(tb_cache)}] = 128'h{'00000000'*4};")

    return tb_cache

def main(asm_file_path):
    cache_lines = read_and_process_file(asm_file_path)
    for line in cache_lines:
        print("    "+line)
  

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate cache lines from asm code')
    parser.add_argument('--asm', required=True, help='Path to the asm txt file')
    
    args = parser.parse_args()
    
    main(args.asm)
