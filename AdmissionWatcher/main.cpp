#include <array>
#include <cassert>
#include <chrono>
#include <fstream>
#include <functional>
#include <iostream>
#include <memory>
#include <optional>
#include <regex>
#include <sstream>
#include <thread>
#include <unordered_map>

#include "lex.h"
#include <tgbot/tgbot.h>

namespace telegram {

static TgBot::Bot Bot("*stripped*");
static constexpr int kChatID = 0; // *stripped*
static constexpr int kMessageCharLimit = 4000;
static const std::string kBulletList = "- ";
static const std::string kBoldTagOpen = "<b>";
static const std::string kBoldTagClose = "</b>";
static const std::string kCodeTagOpen = "<code>";
static const std::string kCodeTagClose = "</code>";

void SendMessage(const std::string& content) {
   Bot.getApi().sendMessage(kChatID, content, false, 0, std::make_shared<TgBot::GenericReply>(), "HTML");
}

void SendPaginatedMessage(const std::string& content) {
    if (content.size() <= kMessageCharLimit) {
        return SendMessage(content);
    }

    std::string message;
    std::istringstream content_stream(content);

    for (std::string line; std::getline(content_stream, line, '\n');){
        if ((message.size() + line.size()) >= kMessageCharLimit) {
            SendMessage(message);
            message.clear();
        }

        message += line;
        message += '\n';
    }
}

} // namespace telegram

namespace diff {

// T must not be a reference
template <typename T>
using ValueWrapper = std::optional<std::reference_wrapper<T>>;

enum class Change {
    kModified,
    kAdded,
    kRemoved,
};

class ResultBase {
public:
    virtual std::string Print() const = 0;
    virtual ~ResultBase() = default;
};

template <typename Left, typename Right>
class Result : public ResultBase {
public:
    Result(Change type, const std::string& field, ValueWrapper<Left> left, ValueWrapper<Right> right)
        : type_(type), field_(field), left_(left), right_(right) {}

public:
    std::string Print() const override {
        using namespace telegram;

        std::stringstream result;

        result << kBulletList << "Поле "
            << kCodeTagOpen << '"' << field_ << '"' << kCodeTagClose;

        switch (type_) {
            case Change::kModified:
                {
                    result << " было " << kCodeTagOpen << '"' << left_->get() << '"' << kCodeTagClose
                        << ", изменено на " << kCodeTagOpen << '"' << right_->get() << '"' << kCodeTagClose;

                    break;
                }
            case Change::kAdded:
                {
                    result << " добавлено: " << kCodeTagOpen << '"' << right_->get() << '"' << kCodeTagClose;

                    break;
                }
            case Change::kRemoved:
                {
                    result << " удалено, было " << kCodeTagOpen << '"' << left_->get() << '"' << kCodeTagClose;

                    break;
                }
            default:
                {
                    throw std::domain_error("Invalid change type (" + std::to_string(static_cast<int>(type_)) + ")");
                }
        }

        return result.str();
    }

private:
    Change type_;
    std::string field_;
    ValueWrapper<Left> left_;
    ValueWrapper<Right> right_;
};

class Diff {
public:
    template <typename Left, typename Right>
    void Compare(const std::string& field, ValueWrapper<Left> left, ValueWrapper<Right> right) {
        bool left_exists = left.has_value();
        bool right_exists = right.has_value();

        if (left_exists != right_exists) {
            if (left_exists) {
                AddDiff(Change::kRemoved, field, left, right);
            } else {
                AddDiff(Change::kAdded, field, left, right);
            }
        } else if (left_exists && (left->get() != right->get())) {
            //     ^
            // It's enough to compare left_exists for truth,
            // because first expression guarantees right_exists has same value
            AddDiff(Change::kModified, field, left, right);
        }
    }

    template <typename Class, typename Value>
    void CompareMembers(const std::string& field, const Class& left, const Class& right, Value Class::* member) {
        Compare(field, ValueWrapper<const Value>(left.*member), ValueWrapper<const Value>(right.*member));
    }

    template <typename Class, typename Value, typename Predicate>
    void CompareMembers(const std::string& field, const Class& left, const Class& right,
        Value Class::* member, Predicate predicate) {
        Compare(field, ValueWrapper<const Value>(predicate(left.*member)),
            ValueWrapper<const Value>(predicate(right.*member)));
    }

    void PrintDiffs(std::ostream& out) const {
        bool first = true;

        for (const auto& diff : diffs_) {
            if (!first) {
                out << '\n';
            }
            first = false;

            out << diff->Print();
        }
    }

    std::string SerializeDiffs() const {
        std::string output;
        bool first = true;

        for (const auto& diff : diffs_) {
            if (!first) {
                output += '\n';
            }
            first = false;

            output += diff->Print();
        }

        return output;
    }

    size_t Count() const {
        return diffs_.size();
    }

private:
    template <typename Left, typename Right>
    void AddDiff(Change type, const std::string& field, ValueWrapper<Left> left, ValueWrapper<Right> right) {
        diffs_.emplace_back(std::make_unique<Result<Left, Right>>(type, field, left, right));
    }

private:
    std::vector<std::unique_ptr<ResultBase>> diffs_;
};

}

namespace competition {

namespace service {

const static TgBot::Url kListUrl("*stripped*");
static TgBot::BoostHttpOnlySslClient client;
static const std::string kBackupPath = "competition_backup.txt";

std::string GetContent() {
    try {
        return client.makeRequest(kListUrl, {});
    } catch (std::exception& ex) {
        std::cerr << "competition::service::GetContent exception: " << ex.what() << std::endl;
        return "";
    }
}

std::string GetContentFromBackup() {
    std::ifstream file(kBackupPath, std::ios::binary);

    assert(file);

    std::ostringstream buffer;
    buffer << file.rdbuf();

    return buffer.str();
}

void SaveContentToBackup(const std::string& content) {
    std::ofstream file(kBackupPath, std::ios::binary);

    assert(file);

    file << content;
}

} // namespace service

struct Student final {
    static const std::unordered_map<size_t, std::string> kPrintableFields;

    diff::Diff Compare(const Student& other) const {
        static const auto make_optional = [](const std::string& value) -> diff::ValueWrapper<const std::string> {
            if (value.empty()) {
                return std::nullopt;
            }

            return value;
        };

        diff::Diff diff;

        diff.CompareMembers(kPrintableFields.at(offsetof(Student, color_)), *this, other, &Student::color_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, snils_)), *this, other, &Student::snils_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, id_)), *this, other, &Student::id_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, individual_achievements_)), *this, other, &Student::individual_achievements_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, document_type_)), *this, other, &Student::document_type_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, is_original_given_uni_)), *this, other, &Student::is_original_given_uni_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, is_original_given_egpu_)), *this, other, &Student::is_original_given_egpu_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, is_agreement_signed_)), *this, other, &Student::is_agreement_signed_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, date_of_decline_)), *this, other, &Student::date_of_decline_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, notes_)), *this, other, &Student::notes_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, dormitory_)), *this, other, &Student::dormitory_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, order_of_enrollment_)), *this, other, &Student::order_of_enrollment_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, order_of_expulsion_)), *this, other, &Student::order_of_expulsion_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, took_entrance_exams_)), *this, other, &Student::took_entrance_exams_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, bzd_score_)), *this, other, &Student::bzd_score_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, russian_score_)), *this, other, &Student::russian_score_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, composition_score_)), *this, other, &Student::composition_score_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, sum_)), *this, other, &Student::sum_, make_optional);
        diff.CompareMembers(kPrintableFields.at(offsetof(Student, i_enrollment_)), *this, other, &Student::i_enrollment_, make_optional);
        return diff;
    }

    const std::string& GetID() const {
        return id_;
    }

    const std::string& GetPlace() const {
        return i_;
    }

    friend std::ostream& operator<<(std::ostream& out, const Student& student) {
        return out <<
            "color_: " << student.color_ << " " <<
            "i_: " << student.i_ << " " <<
            "snils_: " << student.snils_ << " " <<
            "id_: " << student.id_ << " " <<
            "individual_achievements_: " << student.individual_achievements_ << " " <<
            "document_type_: " << student.document_type_ << " " <<
            "is_original_given_uni_: " << student.is_original_given_uni_ << " " <<
            "is_original_given_egpu_: " << student.is_original_given_egpu_ << " " <<
            "is_agreement_signed_: " << student.is_agreement_signed_ << " " <<
            "date_of_decline_: " << student.date_of_decline_ << " " <<
            "notes_: " << student.notes_ << " " <<
            "dormitory_: " << student.dormitory_ << " " <<
            "order_of_enrollment_: " << student.order_of_enrollment_ << " " <<
            "order_of_expulsion_: " << student.order_of_expulsion_ << " " <<
            "took_entrance_exams_: " << student.took_entrance_exams_ << " " <<
            "bzd_score_: " << student.bzd_score_ << " " <<
            "russian_score_: " << student.russian_score_ << " " <<
            "composition_score_: " << student.composition_score_ << " " <<
            "sum_: " << student.sum_ << " " <<
            "i_enrollment_: " << student.i_enrollment_;
    }

    std::string color_;
    std::string i_;
    std::string snils_;
    std::string id_;
    std::string individual_achievements_;
    std::string document_type_;
    std::string is_original_given_uni_;
    std::string is_original_given_egpu_;
    std::string is_agreement_signed_;
    std::string date_of_decline_;
    std::string notes_;
    std::string dormitory_;
    std::string order_of_enrollment_;
    std::string order_of_expulsion_;
    std::string took_entrance_exams_;
    std::string bzd_score_;
    std::string russian_score_;
    std::string composition_score_;
    std::string sum_;
    std::string i_enrollment_;
};

const std::unordered_map<size_t, std::string> Student::kPrintableFields = {
    {offsetof(Student, color_), "Цвет"},
    {offsetof(Student, i_), "№"},
    {offsetof(Student, snils_), "СНИЛС"},
    {offsetof(Student, id_), "Идентификационный номер"},
    {offsetof(Student, individual_achievements_), "Индивидуальные достижения"},
    {offsetof(Student, document_type_), "Документ об образовании"},
    {offsetof(Student, is_original_given_uni_), "Подлинник ВУЗ"},
    {offsetof(Student, is_original_given_egpu_), "Подлинник ЕГПУ"},
    {offsetof(Student, is_agreement_signed_), "Согласие о зачислении"},
    {offsetof(Student, date_of_decline_), "Дата отзыва согласия"},
    {offsetof(Student, notes_), "Примечание"},
    {offsetof(Student, dormitory_), "Общежитие"},
    {offsetof(Student, order_of_enrollment_), "Приказ о зачислении"},
    {offsetof(Student, order_of_expulsion_), "Приказ об отчислении"},
    {offsetof(Student, took_entrance_exams_), "Без вступительных испытаний"},
    {offsetof(Student, bzd_score_), "Балл за Безопасность жизнедеятельности"},
    {offsetof(Student, russian_score_), "Балл за русский"},
    {offsetof(Student, composition_score_), "Балл за композицию"},
    {offsetof(Student, sum_), "Сумма баллов"},
    {offsetof(Student, i_enrollment_), "К зачислению" },
};

namespace parser {

using List = std::unordered_map<std::string, Student>;

static const std::string kUpdateDatePattern("<strong>ДАТА: ([^<]-)</strong>");
static const std::string kRowPattern("<tr([^>]-)>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*<td[^>]+>(.-)</td>%s*</tr>");
static const std::string kColorPattern("#%x+");
static const std::unordered_map<std::string_view, std::string> kColors = {
    {"#F8D7DA", "красный"},
    {"#FFF3CD", "жёлтый"},
    {"#D4EDDA", "зелёный"}
};
static const std::unordered_map<std::string_view, std::string> kKnownIDs = {
    {"00-*stripped*", "*stripped*"},
    {"00-*stripped*", "*stripped*"}
};

static std::string LastUpdateDate;

std::string MakeColorReadable(std::string_view color) {
    if (auto color_name = kColors.find(color); color_name != std::end(kColors)) {
        return color_name->second;
    }

    return "";
}

std::string MarkKnownIDs(const std::string& id) {
    if (auto known_id = kKnownIDs.find(id); known_id != std::end(kKnownIDs)) {
        return id + " (" + known_id->second + ")";
    }

    return id;
}

List Parse(const std::string& content) {
    using namespace competition;

    auto date_match = pg::lex::match(content, parser::kUpdateDatePattern);

    if (!date_match) {
        std::cerr << "Update date not found" << std::endl;

        return {};
    }

    if (std::string_view update_date = date_match.at(0); LastUpdateDate != update_date) {
        std::cout << update_date << std::endl;
        LastUpdateDate = std::string(update_date);
    } else {
        return {};
    }

    //First we need to get all rows from bottom to top. Because there might be some duplicates with lower score.
    std::vector<Student> ordered_list;

    for (auto& row_match : pg::lex::context(content, parser::kRowPattern)) {
        assert(row_match.size() == 20);

        std::string color;

        if (auto color_match = pg::lex::match(row_match.at(0), parser::kColorPattern)) {
            color = MakeColorReadable(color_match.at(0));
        }

        auto id = MarkKnownIDs(std::string(row_match.at(3)));

        ordered_list.emplace_back(Student{
            color,
            std::string(row_match.at(1)), std::string(row_match.at(2)), id,
            std::string(row_match.at(4)), std::string(row_match.at(5)),
            std::string(row_match.at(6)), std::string(row_match.at(7)),
            std::string(row_match.at(8)), std::string(row_match.at(9)),
            std::string(row_match.at(10)), std::string(row_match.at(11)),
            std::string(row_match.at(12)), std::string(row_match.at(13)),
            std::string(row_match.at(14)), std::string(row_match.at(15)),
            std::string(row_match.at(16)), std::string(row_match.at(17)),
            std::string(row_match.at(18)), std::string(row_match.at(19))
            });
    }

    std::reverse(std::begin(ordered_list), std::end(ordered_list));

    List parsed_list;

    for (auto& student : ordered_list) {
        auto [it, stat] = parsed_list.try_emplace(student.GetID(), std::move(student));

        assert(stat);
    }

    return parsed_list;
}

} // namespace parser

class DiffChecker {
public:
    DiffChecker(bool use_backup = false)
        : db_(competition::parser::Parse(
            use_backup ? competition::service::GetContentFromBackup() : competition::service::GetContent()
        )) {
        if (db_.empty()) {
            std::cerr << "db_ is empty, using backup..." << std::endl;
            db_ = competition::parser::Parse(competition::service::GetContentFromBackup());
        }
    }

    void Check() {
        auto content = competition::service::GetContent();
        auto new_list = competition::parser::Parse(content);

        if (new_list.empty()) {
            return;
        }

        std::ostringstream output;

        for (const auto& [id, student] : db_) {
            if (!new_list.count(id)) {
                output << telegram::kBoldTagOpen << "Абитуриент " << student.GetID() << " (" << student.GetPlace() << ") больше не в списке" << telegram::kBoldTagClose << '\n';
                continue;
            }

            if (diff::Diff diff = student.Compare(new_list.at(id)); diff.Count() != 0) {
                output << telegram::kBoldTagOpen << student.GetID() << " (" << student.GetPlace() << ')' << telegram::kBoldTagClose << '\n';
                diff.PrintDiffs(output);
                output << '\n';
            }
        }

        for (const auto& [id, student] : new_list) {
            if (!db_.count(id)) {
                output << telegram::kBoldTagOpen << "Новый абитуриент: " << student.GetID() << " (" << student.GetPlace() << ")" << telegram::kBoldTagClose << '\n';
            }
        }

        if (std::string output_string = output.str(); !output_string.empty()) {
            std::cout << output_string << std::endl;

            telegram::SendPaginatedMessage(output_string);
        }

        db_ = new_list;
        competition::service::SaveContentToBackup(content);
    }

private:
    parser::List db_;
};

} // namespace competition

int main(int argc, char* argv[]) {
    bool use_backup = argc == 2 && std::string(argv[1]) == "backup";

    competition::DiffChecker checker(use_backup);

    while (true) {
        try {
            checker.Check();
        } catch (std::exception& ex) {
            std::cerr << "checker.Check() exception: " << ex.what() << std::endl;
        }

        std::this_thread::sleep_for(std::chrono::minutes(15));
    }
}
