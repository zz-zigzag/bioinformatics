/*

    Copyright (C) 2015 zz_zigzag <zz_zigzag@outlook.com>

*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/stat.h>

#define PACKAGE_VERSION "0.2.7"

static int usage()
{
    fprintf(stderr, "\n");
    fprintf(stderr, "Program: vcf_del (format the <deletion> vcf file)\n");
    fprintf(stderr, "Version: %s\n", PACKAGE_VERSION);
    fprintf(stderr, "Contact: zz_zigzag <zz_zigzag@outlook.com>\n\n");
    fprintf(stderr, "Usage:   vcf_del [option] <in.vcf> <out.vcf>\n\n");
    fprintf(stderr, "Options: -f        remove the overlapping deletions\n");
    fprintf(stderr, "                   and only include the pure deletions.\n");
    fprintf(stderr, "         -c STRING the chromosome to output(default all).\n");
    fprintf(stderr, "         -n STRING the sample to output(need -g, default all).\n");
    fprintf(stderr, "         -i INT    the minimum length for deletions(default 0).\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "         -g        output with the genotype of individual.\n");
    fprintf(stderr, "         -o        only output the genotype of deletion existed\n");
    fprintf(stderr, "         -s        simple genotype: 0 or 1\n");

    return 1;
}

int getFileSize(char *filename)
{
    struct stat fileStat;
    int result = stat(filename, &fileStat);
    if(result != 0) {
        perror(filename);
        exit(1);
    }
    return fileStat.st_size;
}

void openFile(FILE **file, char *filename, char *type)
{
    if((*file = fopen(filename, type)) == NULL) {
        perror(filename);
        exit(1);
    }
    return ;
}

int main(int argc, char* argv[])
{
    char c;
    int filterMode = 0;
    int minL = 0;
    int outGenotype = 0;
    int onlyExist = 0;
    int simpleGenotype = 0;
    char *chromosome = NULL;
    char *indiName = NULL;
    while((c = getopt(argc, argv, "fgi:c:n:")) != EOF) {
        switch(c) {
        case 'f':
            filterMode = 1;
            break;
        case 'g':
            outGenotype = 1;
            break;
        case 'o':
            onlyExist = 1;
            break;
        case 's':
            simpleGenotype = 1;
            break;
        case 'c':
            chromosome = optarg;
            break;
        case 'n':
            indiName = optarg;
            break;
        case 'i':
            minL = atoi(optarg);
            break;
        }
    }
    if(argc - optind != 2)
        return usage();


    FILE *fpin, *fpout;
    openFile(&fpin, argv[optind], "r");
    openFile(&fpout, argv[optind+1], "w");

    long fileSize = getFileSize(argv[optind]);
    char *buf = (char *)malloc(fileSize + 10);

    if(fileSize == 0 || fread(buf, fileSize, 1, fpin) != 1) {
        perror(argv[optind]);
        return -1;
    }

    char *str, *s_tab, *s_line, *str_line, *str_tab;
    str = s_tab = s_line = str_line = str_tab = NULL;

    int brk1, brk2, svlen;
    svlen = brk1 = brk2 = 0;
    int indiNum, indiCnt, varCnt;
    char *chr = NULL;
    char *prechr= NULL;
    int prebrk2 = 0;

    s_line = strtok_r(buf, "\n", &str_line);
    varCnt = 0;
    indiNum = -1;
    do {
        if(s_line[0] == '#') {   //remove the head of file # or ##
            indiNum = 0;
            if(outGenotype == 1 && s_line[1] != '#') { //leave the last line of head when output genotype
                //fprintf(fpout, "CHROM\tPOS\tEND\tSVLEN\t");
                s_tab = strstr(s_line, "FORMAT");
                s_tab = strtok_r(s_tab, "\t", &str_tab);
                if(indiName != NULL) {
                    while((s_tab = strtok_r(NULL, "\t", &str_tab)) != NULL) {
                        if(strcmp(s_tab, indiName) == 0) {
                            //fprintf(fpout, "%s\n", s_tab);
                            break;
                        }
                        indiNum++;
                    }
                    if(s_tab == NULL) {
                        fprintf(stderr, "can not find %s\n", indiName);
                        exit(1);
                    }
                }
            }
            continue;
        }
        if (indiNum == -1) {
            fprintf(stderr, "can not find %s\n", indiName);
            exit(1);
        }
        //filtered by chromosome
        s_tab = strtok_r(s_line, "\t", &str_tab);
        chr = s_tab;
        if(chromosome != NULL) {
            if(strcmp(chr, chromosome) != 0)
                continue;
        }

        s_tab = strtok_r(NULL, "\t", &str_tab);

        brk1 = atoi(s_tab);
        if(filterMode && !outGenotype)
            if(prechr != NULL && !strcmp(prechr, chr) && brk1 < prebrk2) {
                //remove the overlapped variation
                //this start position can not between the previous brk1 and brk2
                continue;
            }

        strtok_r(NULL, "\t", &str_tab);
        strtok_r(NULL, "\t", &str_tab);

        s_tab = strtok_r(NULL, "\t", &str_tab);
        if(filterMode)
            if(strlen(s_tab) > 1 && s_tab[0] != '<') {
                //e.g. REF ALT | ACTTCGGA ATC
                //not pure deletion
                continue;
            }

        strtok_r(NULL, "\t", &str_tab);
        strtok_r(NULL, "\t", &str_tab);

        s_tab = strtok_r(NULL, "\t", &str_tab);

        str = strtok_r(s_tab, ";", &s_tab);
        do {
            if(strstr(str, "END") == str) {
                sscanf(str, "END=%d", &brk2);
                brk2 = brk2+1;
                break;
            }
        } while((str = strtok_r(NULL, ";", &s_tab)) != NULL);
        svlen = brk2 - brk1 - 1;
        //filtered by min length
        if(svlen < minL)
            continue;
        if(outGenotype) {
            //if have -g
            indiCnt = 0;
            strtok_r(NULL, "\t", &str_tab);
            if(indiName == NULL) {      // output all the sample
                fprintf(fpout, "%s\t%d\t%d", chr, brk1, brk2);
                while((s_tab = strtok_r(NULL, "\t", &str_tab)) != NULL) {
                    if (!simpleGenotype)
                        fprintf(fpout, "\t%c/%c", s_tab[0], s_tab[2]);
                    else {
                        int temp = s_tab[0] - '0' + s_tab[1] - '0';
                        if (temp == 2) temp = 1;
                        fprintf(fpout, "\t%d", temp);
                    }
                    if(!isdigit(s_tab[0]) || !isdigit(s_tab[2]))
                        fprintf(stderr, "[varID:%d, indiID:%d] genotype: %c/%c\n", varCnt, indiCnt, s_tab[0], s_tab[2]);
                    indiCnt++;
                }
                fprintf(fpout, "\n");
            } else {
                while((s_tab = strtok_r(NULL, "\t", &str_tab)) != NULL) {
                    if(indiCnt == indiNum) { //find the sample
                        if(onlyExist == 0 || s_tab[0] != '0' || s_tab[2] != '0' ) {
                            if(filterMode && prechr != NULL && !strcmp(prechr, chr) && brk1 < prebrk2) {
                                continue;
                            }
                            if(!isdigit(s_tab[0]) || !isdigit(s_tab[2])) {
                                fprintf(stdout, "[varID:%d, indiID:%d] genotype: %c/%c\n", varCnt, indiCnt, s_tab[0], s_tab[2]);
                                varCnt--;
                            } else {
                                fprintf(fpout, "%s\t%d\t%d", chr, brk1, brk2);
                                if (!simpleGenotype)
                                    fprintf(fpout, "\t%c/%c\n", s_tab[0], s_tab[2]);
                                else {
                                    int temp = s_tab[0] - '0' + s_tab[1] - '0';
                                    if (temp == 2) temp = 1;
                                    fprintf(fpout, "\t%d\n", temp);
                                }

                            }
                            varCnt++;
                            prechr = chr;
                            prebrk2 = brk2;
                        }
                        break;
                    }
                    indiCnt++;
                }
            }
        } else {
            fprintf(fpout, "%s\t%d\t%d\n", chr, brk1, brk2);
            varCnt++;
            prechr = chr;
            prebrk2 = brk2;
        }
    } while((s_line = strtok_r(NULL, "\n", &str_line)) != NULL);
    fclose(fpin);
    fclose(fpout);

    if(indiName)
        fprintf(stdout, "NAME: %s\t", indiName);
    else if(outGenotype)
        fprintf(stdout, "INDI_CNT: %d\t", indiCnt);
    if(chromosome)
        fprintf(stdout, "CHROM: %s\t", chromosome);
    fprintf(stdout, "VAR_CNT: %d\n", varCnt);
    return 0;
}
