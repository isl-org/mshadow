#include <gtest/gtest.h>
#include <iostream>

#include "mshadow/tensor.h"

using namespace mshadow;
using namespace mshadow::expr;

TEST(Buide, BasicStream) {
  // Intialize tensor engine before using tensor operation, needed for CuBLAS
  InitTensorEngine<gpu>(0);

  // Create a 2 x 5 tensor, from existing space
  Stream<gpu> *sm1 = NewStream<gpu>(0);
  Stream<gpu> *sm2 = NewStream<gpu>(0);
  printf("sm1 %p\n", sm1);
  printf("sm2 %p\n", sm2);
  Tensor<gpu, 2, float> ts1 =
      NewTensor<gpu, float>(Shape2(2, 5), 0.0f, false, sm1);
  Tensor<gpu, 2, float> ts2 =
      NewTensor<gpu, float>(Shape2(2, 5), 0.0f, false, sm2);
  ts1 = 1;  // Should use stream 0.
  ts2 = 2;  // Should use stream 1. Can run in parallel with stream 0.
  Tensor<gpu, 2> res = NewTensor<gpu, float>(Shape2(2, 2), 0.0f, false, sm1);
  res.stream_ = NewStream<gpu>(0);
  res = dot(ts1, ts2.T());  // Should use stream 2.

  Tensor<cpu, 2> cpu_res = NewTensor<cpu, float>(Shape2(2, 2), 0.0f);
  Copy(cpu_res, res, sm2);  // default stream, should be 0.

  for (index_t i = 0; i < cpu_res.size(0); ++i) {
    for (index_t j = 0; j < cpu_res.size(1); ++j) {
      printf("%.2f ", cpu_res[i][j]);
    }
    printf("\n");
  }
  // shutdown tensor enigne after usage
  DeleteStream(sm1);
  DeleteStream(sm2);
  ShutdownTensorEngine<gpu>();
}
