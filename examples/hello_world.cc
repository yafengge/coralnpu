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
// Unicode code points: U+4F60 (你) U+597D (好)
const char hello_message[] = "\xe4\xbd\xa0\xe5\xa5\xbd";
constexpr int BUFFER_SIZE = sizeof(hello_message);
char output_buffer[BUFFER_SIZE] __attribute__((section(".data")));

int main() {
  // Copy the hello message to output buffer
  memcpy(output_buffer, hello_message, BUFFER_SIZE);
  
  // Return the length of the message (excluding null terminator)
  return BUFFER_SIZE - 1;
}
