#!/usr/bin/env bash

returns_0()        { return 0;   }
returns_1()        { return 1;   }
returns_127()      { return 127; }
last_return_code() { echo "$?";  }

returns_0
last_return_code

returns_1
last_return_code

returns_127
last_return_code
