/*  The MIT License

    Copyright (C) 2015 zz_zigzag <zz_zigzag@outlook.com>

*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/stat.h>

#define PACKAGE_VERSION "0.1.1"

typedef struct
{
    char *chr;
    char *ref, *alt;
    int brk1, brk2, len;
    char type;  //D:deletion    I:insertion
} VARIATION;

static int usage()
{
    fprintf(stderr, "\n");
    fprintf(stderr, "Program: DonorSim (Simulator donors by injecting variation to reference chromosome.)\n");
    fprintf(stderr, "Version: %s\n", PACKAGE_VERSION);
    fprintf(stderr, "Contact: zz_zigzag <zz_zigzag@outlook.com>\n\n");
    fprintf(stderr, "Usage:   DonorSim  [-i/D/I] [options]\n\n");
    fprintf(stderr, "Function mode\n");
    fprintf(stderr, "         -i        Variation of indel\n");
    fprintf(stderr, "                   format: chr start ref alt\n");
    fprintf(stderr, "         -D        Variation of deletion\n");
    fprintf(stderr, "                   format: chr start end (deletion_length = end-start-1)  \n");
    fprintf(stderr, "         -I        Variation of insertion\n");
    fprintf(stderr, "                   format: chr start ref alt\n");
    fprintf(stderr, "Required parameters:\n");
    fprintf(stderr, "         -v FILE   Variation list file\n");
    fprintf(stderr, "         -n INT    Number of donors\n");
    fprintf(stderr, "         -r FILE   Reference chromosome file\n");
    fprintf(stderr, "         -c STRING Chromosome name\n");
    fprintf(stderr, "         -p DOUBLE Probability of presence for each variation\n");

    fprintf(stderr, "\n");
    return 1;
}

int getFileSize(char *filename);
int getFileRowsNumber(char *filename);
VARIATION * readVCF(int mode, char *chr, char *filename, int *varSize);
void addVar(int mode, VARIATION *v, int vSize, char *refFile, int cnt, int p);
void openFile(FILE **file, char *filename, char *type);



int main(int argc, char *argv[])
{
    int mode = -1; //indel or deletion or insertion
    char *varFile, *refFile;
    varFile = refFile = NULL;
    char *chr = NULL;
    int cnt = 0, p = 0;
    char c;
    while((c = getopt(argc, argv, "iDIv:n:r:c:p:")) != EOF)
    {
        switch(c)
        {
        case 'D':
            mode = 0;
            break;
        case 'I':
            mode = 1;
            break;
        case 'i':
            mode = 2;
            break;
        case 'v':
            varFile = optarg;
            break;
        case 'r':
            refFile = optarg;
            break;
        case 'n':
            cnt = atoi(optarg);
            break;
        case 'c':
            chr = optarg;
            break;
        case 'p':
            p = (int)(atof(optarg) * 100);
            break;
        default:
            return usage();
            break;
        }
    }
    if(mode == -1 || varFile == NULL || p == 0 ||\
            refFile == NULL || chr == NULL || cnt == 0)
        return usage();
    int varSize;
    VARIATION *v = readVCF(mode, chr, varFile, &varSize);
    addVar(mode, v, varSize, refFile, cnt, p);



    return 0;
}

int getFileSize(char *filename)
{
    struct stat fileStat;
    stat(filename, &fileStat);
    return fileStat.st_size;
}

int getFileRowsNumber(char *filename)
{
    char *sys = (char *)malloc(strlen(filename) + 10);
    sprintf(sys,"wc -l %s", filename);
    FILE *fp = popen(sys, "r");
    int n;
    if(fscanf(fp, "%d", &n) != 1)
        exit(1);
    pclose(fp);
    return n;
}

void openFile(FILE **file, char *filename, char *type)
{
    if((*file = fopen(filename, type)) == NULL)
    {
        fprintf(stderr, "[DonorSim_openFile] ERROR: Could not open %s.\n", filename);
        exit(1);
    }
    return ;
}

VARIATION *readVCF(int mode, char *chr, char *filename, int *varSize)
{
    FILE *f;
    openFile(&f, filename, "r");
    VARIATION *v = (VARIATION *)calloc(getFileRowsNumber(filename), sizeof(VARIATION));
    int fileSize = getFileSize(filename);
    char *buf = (char *)malloc(fileSize);
    if(fread(buf, fileSize, 1, f) != 1)
    {
        fprintf(stderr, "[DonorSim_readVCF] ERROR: Could not read %s.\n", filename);
        exit(1);
    }

    char *t, *str_line, *str_tab;
    t = str_line = str_tab = NULL;

    int varp = 0;
    t = strtok_r(buf, "\n", &str_line);
    if(t == NULL)
    {
        fprintf(stderr, "[DonorSim_readVCF] ERROR: %s content error.\n", filename);
    }
    do
    {
        if(mode == 0)   //deletion      format: chr start end
        {
            t = strtok_r(t, "\t", &str_tab);
            if(strcmp(t, chr) != 0)
                continue;
            v[varp].chr = t;
            sscanf(str_tab, "%d%d", &v[varp].brk1, &v[varp].brk2);
            v[varp].len = v[varp].brk2 - v[varp].brk1 - 1;
            v[varp].type = 'D';
        }
        else if(mode == 2)  //indel     format: chr start ref alt
        {
            t = strtok_r(t, "\t", &str_tab);
            if(strcmp(t, chr) != 0)
                continue;
            v[varp].chr = t;
            t =  strtok_r(NULL, "\t", &str_tab);
            v[varp].brk1 = atoi(t);
            t =  strtok_r(NULL, "\t", &str_tab);
            v[varp].ref = t;
            t =  strtok_r(NULL, "\t", &str_tab);
            v[varp].alt = t;

            int l = strlen(v[varp].ref);
            if(l != 1)
            {
                v[varp].type = 'D';
                v[varp].brk2 = v[varp].brk1 + l;
                v[varp].len = l - 1;
            }
            else
            {
                v[varp].type = 'I';
                v[varp].len = strlen(v[varp].alt) - 1;
            }
        }
        else        //insertion     format: chr start ref alt
        {
            t = strtok_r(t, "\t", &str_tab);
            if(strcmp(t, chr) != 0)
                continue;
            v[varp].chr = t;
            t =  strtok_r(NULL, "\t", &str_tab);
            v[varp].brk1 = atoi(t);
            t =  strtok_r(NULL, "\t", &str_tab);
            v[varp].ref = t;
            t =  strtok_r(NULL, "\t", &str_tab);
            v[varp].alt = t;
            v[varp].type = 'I';
            v[varp].len = strlen(v[varp].alt) - 1;
        }
        varp++;
    }
    while((t = strtok_r(NULL, "\n", &str_line)) != NULL);
    *varSize = varp;
    return v;
}


void addVar(int mode, VARIATION *v, int vSize, char *refFileName, int donorCnt, int p)
{
    int i, j;
    char **varIndi = (char **)calloc(vSize, sizeof(char *));
    for(i = 0; i < vSize; i++)
    {
        varIndi[i] = (char *)calloc(donorCnt, sizeof(char));
    }

    FILE *fpref, *fpdonor;
    char *chr, donorFilename[FILENAME_MAX];
    chr = v[0].chr;
    openFile(&fpref, refFileName, "r");
    int pref, pdonor ,rowSize;
    char t;
    srand(time(0));


    while((t = fgetc(fpref)) != EOF && t != '\n') ;   //read the first line.(>...)
    pref = 0;
    while((t = fgetc(fpref)) != EOF && t != '\n') pref++;
    rowSize = pref;

    for(i = 0; i < donorCnt; i++)
    {
        rewind(fpref);
        pref = 1;
        pdonor = 0;
        sprintf(donorFilename, "%d_%s.fa", i + 1, chr);
        openFile(&fpdonor, donorFilename, "w");
        while((t = fgetc(fpref)) != EOF && t != '\n') fputc(t, fpdonor);   //read the first line.(>...)
        fputc(t, fpdonor);
        for(j = 0; j < vSize; j++)
        {
            varIndi[j][i] = (rand()%100 < p) ? 1 : 0;
            if(varIndi[j][i] == 0)      //pass the variation
                continue;
            while(pref <= v[j].brk1 && (t = fgetc(fpref)) != EOF)
            {
                if(t == '\n')
                    continue;
                pref++;
                pdonor++;
                fputc(t, fpdonor);
                if(pdonor % rowSize == 0)
                    fputc('\n', fpdonor);
            }
            if(v[j].type == 'D')
            {
                while(pref < v[j].brk2 && (t = fgetc(fpref)) != EOF)
                {
                    if(t == '\n')
                        continue;
                    pref++;
                }
            }
            else
            {
                int p = 1;
                while((t = v[j].alt[p++]) != '\0')
                {
                    if(t == '\n')
                        continue;
                    pdonor++;
                    fputc(t, fpdonor);
                    if(pdonor % rowSize == 0)
                        fputc('\n', fpdonor);
                }
            }

        }

        while((t = fgetc(fpref)) != EOF)
        {
            if(t == '\n')
                continue;
            pref++;
            pdonor++;
            fputc(t, fpdonor);
            if(pdonor % rowSize == 0)
                fputc('\n', fpdonor);

        }
        fclose(fpdonor);
        printf("the %d/%d donor finished.\n", i+1, donorCnt);
    }

    char fname1[FILENAME_MAX], fname2[FILENAME_MAX];
    FILE *f1, *f2;
    for(i = 0; i < donorCnt; i++)
    {
        sprintf(fname1, "%d_%s_S", i + 1, chr);
        sprintf(fname2, "%d_%s_V", i + 1, chr);
        openFile(&f1, fname1, "w");
        openFile(&f2, fname2, "w");

        for(j = 0; j < vSize; j++)
        {
            if (mode == 2) {
                fprintf(f1, "%s\t%c\t%d\t%d\t%d\n", chr, v[j].type, v[j].brk1, v[j].type == 'D' ? v[j].brk2 : v[j].len, varIndi[j][i]);
                if(varIndi[j][i])
                    fprintf(f2, "%s\t%c\t%d\t%d\n", chr, v[j].type, v[j].brk1, v[j].type == 'D' ? v[j].brk2 : v[j].len);
            }
            else {
                fprintf(f1, "%s\t%d\t%d\t%d\n", chr, v[j].brk1, v[j].type == 'D' ? v[j].brk2 : v[j].len, varIndi[j][i]);
                if(varIndi[j][i])
                    fprintf(f2, "%s\t%d\t%d\n", chr, v[j].brk1, v[j].type == 'D' ? v[j].brk2 : v[j].len);

            }
        }
        fclose(f1);
        fclose(f2);
    }
    openFile(&f1, "VAR_LIST", "w");
    for(i = 0; i < vSize; i++)
    {
        fprintf(f1, "%s\t%c\t%d\t%d", chr, v[i].type, v[i].brk1, v[i].type == 'D' ? v[i].brk2 : v[i].len);
        for(j = 0; j < donorCnt; j++)
        {
            fprintf(f1, "\t%d", varIndi[i][j]);
        }
        fputc('\n', f1);
    }
    fclose(f1);
    return;
}

