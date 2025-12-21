// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <string.h>

// UTF-8 encoded "你好" (Hello in Chinese)
const char hello_message[] = "\xe4\xbd\xa0\xe5\xa5\xbd";
char output_buffer[16] __attribute__((section(".data")));

int main() {
  // Copy the hello message to output buffer
  for (int i = 0; i < sizeof(hello_message); i++) {
    output_buffer[i] = hello_message[i];
  }
  
  // Return the length of the message
  return sizeof(hello_message) - 1;  // -1 to exclude null terminator
}
