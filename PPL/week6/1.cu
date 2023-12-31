#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define N 1024

__global__ void CUDACount(char *A, char *B, int *len, int *wordLen, int *cnt)
{
    int idx = threadIdx.x, flag = 1;

    if (idx + *wordLen <= *len)
    {
        for (int i = 0; i < *wordLen; i++)
        {
            if (A[idx + i] != B[i])
            {
                flag = 0;
                break;
            }
        }

        if (flag == 1)
            atomicAdd(cnt, 1);
    }
}

int main()
{
    char A[N], B[N];
    char *d_A, *d_B;

    int count = 0, len, wordLen, res;
    int *d_count, *d_len, *d_wordLen;

    printf("Enter String : ");
    scanf("%[^\n]%*c", A);
    printf("String : %s\n\n", A);

    printf("Enter Word to be searched in String : ");
    scanf("%s", B);
    printf("Word : %s\n\n", B);

    len = strlen(A);
    wordLen = strlen(B);

    cudaMalloc((void **)&d_A, strlen(A) * sizeof(char));
    cudaMalloc((void **)&d_B, strlen(B) * sizeof(char));
    cudaMalloc((void **)&d_count, sizeof(int));
    cudaMalloc((void **)&d_len, sizeof(int));
    cudaMalloc((void **)&d_wordLen, sizeof(int));
    cudaMalloc((void **)&res, sizeof(int));

    cudaMemcpy(d_count, &count, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_len, &len, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_wordLen, &wordLen, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_A, A, strlen(A) * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B, strlen(B) * sizeof(char), cudaMemcpyHostToDevice);

    CUDACount<<<1, (strlen(A) - strlen(B) + 1)>>>(d_A, d_B, d_len, d_wordLen, d_count);
    cudaMemcpy(&res, d_count, sizeof(int), cudaMemcpyDeviceToHost);
    printf("Total Occurances of '%s' = %d\n", B, res);
}