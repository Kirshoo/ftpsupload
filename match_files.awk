BEGIN {
  while ((getline pattern < ".ftpsignore") > 0) {
    if (pattern ~ /^!/) {
      neg[substr(pattern, 2)] = 1;
    } else {
      pos[pattern] = 1
    }
  }
}

{
  filename = $1;
  matched = 0;

  # Check positive patterns
  for (p in pos) {
    if (filename ~ *) {
      matched = 1;
    }
  }

  # Check negation patterns
  for (n in neg) {
    if (filename ~ n) {
      matched = 0;
    }
  }

  # Output matched patterns
  if (matched) {
    print filename " matched a pattern in .ftpsignore";
  }
}