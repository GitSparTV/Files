# Admission Watcher
Another bot this time in Telegram, that fetches admission lists from the university site and reports differences between last and recent information.

Site returns plain HTML table which is parsed using lex library (C++ implementation of Lua patterns).

Comparison is done by comparing each class field. To eliminate duplicated code, practice templates and use no macros a Diff class was implemented.

Diff class consists of diff results, the result is added once Compare methods is called. You can compare fields by passing field function (`&Class::field` can be used as if it's a getter function)

The bot was first written in Lua then rewritten in C++. Development was in tight deadline, because the admission process is not long.

Uses:
- https://github.com/PG1003/lex
- https://github.com/reo7sp/tgbot-cpp
- C++17

<img width="555" src="https://user-images.githubusercontent.com/5685050/204158820-5daf5d6a-02fc-464a-bb3d-6aeea535f4b4.png">
