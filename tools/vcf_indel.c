/*  The MIT License

    Copyright (C) 2015 zz_zigzag <zz_zigzag@outlook.com>

*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define PACKAGE_VERSION "0.1.1"

static int usage()
{
    fprintf(stderr, "\n");
    fprintf(stderr, "Program: VCF_INDEL (format the <INDEL> vcf file)\n");
    fprintf(stderr, "Version: %s\n", PACKAGE_VERSION);
    fprintf(stderr, "Contact: zz_zigzag <zz_zigzag@outlook.com>\n\n");
    fprintf(stderr, "Usage:   VCF_INDEL <in.vcf> <out.vcf>\n\n");
    return 1;
}

int main(int argc, char* argv[])
{
    if(argc != 3)
        return usage();

    struct stat fileStat;
    if(stat(argv[1], &fileStat) < 0)
    {
        fprintf(stderr, "[VCF_INDEL] Open %s failed.\n", argv[1]);
        return -1;
    }
    long fileSize = fileStat.st_size;
    FILE *fpin = fopen(argv[1], "r");
    if(fpin == NULL)
    {
        fprintf(stderr, "[VCF_INDEL] Open %s failed.\n", argv[1]);
        return -1;
    }
    FILE *fpout = fopen(argv[2], "w");
    if(fpout == NULL)
    {
        fprintf(stderr, "[VCF_INDEL] Open %s failed.\n", argv[2]);
        return -1;
    }
    char *buf = (char *)malloc(fileSize);
    if(fread(buf, fileSize, 1, fpin) != 1)
    {
        fprintf(stderr, "[VCF_INDEL] read %s failed.\n", argv[2]);
        return -1;
    }
    char *p = buf;

    char *t, *str, *str_line, *str_tab;
    t = str = str_line = str_tab = NULL;

    int brk1, len, len1, len2;
    brk1 = len = 0;

    char *chr, *ref;
    chr = ref = NULL;


    while((t = strtok_r(p, "\n", &str_line)) != NULL)
    {
        p = NULL;
        if(t[0] == '#')
        {
            //fprintf(fpout,"TYPE \"#\"\n");
            continue;
        }
        t = strtok_r(t, "\t", &str_tab);

        chr = t;
        t = strtok_r(NULL, "\t", &str_tab);
        if(atoi(t) > brk1 && brk1+len >= atoi(t))
        {
            continue;
        }
        brk1 = atoi(t);

        t = strtok_r(NULL, "\t", &str_tab);
        ref = strtok_r(NULL, "\t", &str_tab);
        len1 = strlen(ref);
        t = strtok_r(NULL, "\t", &str_tab);
        strtok_r(t, ",", &str);
        len2 = strlen(t);
        if(len2 != 1 && len1 != 1)
            continue;
        if(ref[0] != t[0])
            continue;
        if(abs(len1 - len2) > 50)
            continue;
        len = len1>len2?len1:len2;


        fprintf(fpout, "%s\t%d\t%s\t%s\n", chr,  brk1, ref, t);
    }
    fclose(fpin);
    fclose(fpout);
    return 0;
}
