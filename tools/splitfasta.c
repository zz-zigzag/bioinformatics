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

void openFile(FILE **file, const char *filename, const char *type)
{
    if((*file = fopen(filename, type)) == NULL)
    {
       perror(filename);
       exit(1);
    }
    return ;
}

int main(int argc, char *argv[])
{
    char line[MAX_LINE_BYTE], filename[MAX_LINE_BYTE];
    FILE *fpin, *fpout, *out_file_list;

    fpin = fpout = NULL;

    if(argc != 2) return usage();
    openFile(&fpin, argv[1], "r");
    openFile(&out_file_list, "file_list.txt", "w");

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
            openFile(&fpout, filename, "w");
            fprintf(out_file_list, "%s", line);
        }
        fputs(line, fpout);
    }
    printf("%s finished.\n", filename);
    fclose(fpout);
    fclose(fpin);
    fclose(out_file_list);
    return 0;
}
