/*  The MIT License

    Copyright (C) 2015 zz_zigzag <zz_zigzag@outlook.com>

*/

#include <stdio.h>
#include <stdlib.h>
//#include <unistd.h>


#define PACKAGE_VERSION "0.1.2"

#define MAX_LINE_BYTE 1000

static int usage(void )
{
    fprintf(stderr, "\n");
    fprintf(stderr, "Program: splitfasta (split fasta file by chromosome '<')\n");
    fprintf(stderr, "Version: %s\n", PACKAGE_VERSION);
    fprintf(stderr, "Contact: zz_zigzag <zz_zigzag@outlook.com>\n\n");
    fprintf(stderr, "Usage:   splitfasta <input.fa>\n\n");

    return 1;

}

int main(int argc, char *argv[])
{
    char line[MAX_LINE_BYTE], filename[MAX_LINE_BYTE];
    FILE *fpin, *fpout, *out_file_list;

    fpin = fpout = NULL;

    if(argc != 2) return usage();
    fpin = fopen(argv[1], "r");
    if(!fpin)
    {
        fprintf(stderr, "[splitfasta] %s file open error\n", argv[1]);
        return 1;
    }
    out_file_list = fopen("file_list.txt", "w");
    if(!out_file_list)
    {
        fprintf(stderr, "[splitfasta] file_list.txt file open error\n");
        return 1;
    }
    while(!feof(fpin))
    {
        fgets(line, MAX_LINE_BYTE, fpin);
        if(line[0] == '>')
        {
            if(fpout)
            {
                printf("%s finished.\n", filename);
                fclose(fpout);
            }
            sscanf(&line[1], "%s", filename);
            sprintf(filename, "%s.fa", filename);
            fpout = fopen(filename, "w");
            {
                if(!fpout)
                {
                    fprintf(stderr, "[splitfasta] %s file open error\n", filename);
                    return 1;
                }
                fprintf(out_file_list, "%s", line);
            }
        }
        fputs(line, fpout);
    }
    printf("%s finished.\n", filename);
    fclose(fpout);
    fclose(fpin);
    fclose(out_file_list);
    return 0;
}
