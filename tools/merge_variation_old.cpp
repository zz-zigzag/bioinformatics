#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <map>
#include <string>

using namespace std;

#define PACKAGE_VERSION "0.0.1"

static int usage()
{
    fprintf(stderr, "\n");
    fprintf(stderr, "Program: merge_variation (merge variation by breakpoint\n");
    fprintf(stderr, "Version: %s\n", PACKAGE_VERSION);
    fprintf(stderr, "Contact: zz_zigzag <zz_zigzag@outlook.com>\n\n");
    fprintf(stderr, "Usage:   merge_variation [option] <in_file> <out_file>\n");
    fprintf(stderr, "         The input format is [chrom start end label] and sorted by chrom and start\n");
    fprintf(stderr, "Options: -e FLOAT maximum allowed deviation is -e*sv_length [0.3]\n");
    fprintf(stderr, "         -m INT   maximum allowed deviation [200]\n");
    fprintf(stderr, "         -s STR   label of callers in priorities.\n");
    fprintf(stderr, "         -h       output detail.\n");
    fprintf(stderr, "                  E.g. [pindel/svseq/delly/breakdancer]\n");
    return 1;
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

void openFile(FILE **file, char *filename,const char *type)
{
   if((*file = fopen(filename, type)) == NULL)
   {
       perror(filename);
       exit(1);
   }
   return ;
}

typedef struct {
    char chr[100], caller[100];
    int brk1, brk2;
    int index;
    bool isCovered;      // there is some var same to this, but precise breakpoint prefer others.
}variation;


int main(int argc, char* argv[])
{
    char c;
    double e = 0.3;
    int m = 200;
    bool flag = false;
    char defaultString[100] = {"pindel/svseq/delly/breakdancer"};
    char *labelString = defaultString;
    while((c = getopt(argc, argv, "hs:e:m:")) != EOF) {
        switch(c) {
            case 'h': flag = true; break;
            case 'e': e = atof(optarg); break;
            case 'm': m = atoi(optarg); break;
            case 's': labelString = optarg; break;
        }
    }
    if(argc - optind != 2) return usage();
    char *save, *strLabel;
    save = strLabel = NULL;
    int i = 0;
    map <string, int> label;
    while((strLabel = strtok_r(labelString, "/", &save)) != NULL) {
        string str = strLabel;
        label[str] = i++;
        labelString = NULL;
    }


    FILE *fpin, *fpout;
    openFile(&fpin, argv[optind], "r");
    openFile(&fpout, argv[optind+1], "w");
    int varCnt = getFileRowsNumber(argv[optind]);
    variation *var = (variation *)malloc(varCnt * sizeof(variation));

    i = 0;
    int diff;
    while(fscanf(fpin, "%s%d%d%s", var[i].chr, &var[i].brk1, &var[i].brk2, var[i].caller) !=EOF) {
        var[i].isCovered = false;
        string str = var[i].caller;
        var[i].index = label[str];
        diff = e * (var[i].brk2 - var[i].brk1);
        if (diff > m) diff = m;
        int j = i - 1;
        for(j = i - 1; j >= 0; --j) {
            if (var[i].brk1 - var[j].brk1 > diff) break;
            else if (abs(var[i].brk2 - var[j].brk2) <= diff) {
                if (var[j].isCovered) continue;
                if (var[i].index <= var[j].index) {
                    var[j].isCovered = true;
                }
                else var[i].isCovered = true;
            }
        }
        ++i;
    }
    varCnt = i;
    if (flag == true) {
        for (i = 0; i < varCnt; ++i) {
            fprintf(fpout, "%s\t%d\t%d\t%s", var[i].chr, var[i].brk1, var[i].brk2, var[i].caller);
            if (var[i].isCovered) fprintf(fpout, "\t-");
            fprintf(fpout, "\n");

        }
    }
    else {
        for (i = 0; i < varCnt; ++i) {
            if (!var[i].isCovered ) {
                fprintf(fpout, "%s\t%d\t%d\t%s\n", var[i].chr, var[i].brk1, var[i].brk2, var[i].caller);
            }
        }
    }


    return 0;
}
