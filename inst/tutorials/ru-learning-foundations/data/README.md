# RU L2 synthetic teaching fixtures — provenance v1

These files were authored by RU L2 solely for instruction. No readings
are empirical, no participants have been enrolled, and row uniqueness
does not establish independent sampled units. Unit declarations below
are **source metadata**, not deductions from CSV column names.

**Guided — sites-intro-v1.csv**

- Content ID: ru.learning.foundation.03.sites-intro-v1.
- SHA-256: 3166dcb4137ce10342f5bed98004c71e28e3aace1a0c088c7fa7c33da8f3834a.
- UTF-8, LF endings, exactly 81 bytes.
- row_key: character log-record key G001–G004, not participant identifier.
- site_group: character site category North/South, repeated across rows.
- reading: numeric **degrees Celsius**, established by this source card.
- Empty reading: NA, never zero. Four log rows, 3 observed, 1 absent.
- Only with explicit observed-case exclusion: mean 17 Celsius.
- No independent-sampling claim.

**Independent transfer — sites-transfer-v1.csv**

- Content ID: ru.learning.foundation.03.sites-transfer-v1.
- SHA-256: 45879c7bc71dc297f5b862f090931637f9d0ddfb718c4107baed1ca7c773c26a.
- UTF-8, LF endings, exactly 162 bytes.
- record_code: character log-record code with leading zeros, not participant ID.
- location_group: repeated character category with a quoted comma in one label.
- reading: numeric **degrees Fahrenheit**, established by this source card.
- quality_flag: synthetic character observation label, not instrument certification.
- Empty reading: NA. Five log rows, 4 observed, 1 absent.
- Only with explicit observed-case exclusion: mean 70 Fahrenheit.
- No independent-sampling claim; the exercise is formative, not a secure exam.

`system.file("tutorials","ru-learning-foundations","data",
             "sites-intro-v1.csv",package="rulearn",mustWork=TRUE)`
is an installed, read-only package lookup, not a path in the learner's
project. Learners may intentionally copy to an unused project filename
after checking for collisions; RU must never overwrite their files.