// Copyright ktw361 2020 
// Distributed under the Boost license, Version 1.0.
// (See accompanying file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#include <iostream>
#include <cstdlib>
#include <string>
#include <fstream>
#include <streambuf>

#include <jsoncons/json.hpp>
#include <jsoncons_ext/jsonpath/jsonpath.hpp>

const int PAD = 16;

const std::string COMMENT = "# ";

class Jcat {
public:
    /* 
     * @params:
     *  notebook : A parsed json of notebook content
     *  str      : Stream object, e.g. std::cout
     *  align    : Align prompt for copy. (e.g. IN [...], OUT [...])
     *  pad_witdh: Padding width for prompt, when align == false
     *
     */
    Jcat(jsoncons::json const &notebook, 
         std::ostream &str, 
         bool align,
         int pad_width) : 
        root(notebook), str(str), pad_width(pad_width), align(align)
    {
        padding = align ? "" : std::string(pad_width, ' ');
    }

    // Returns -1 on error.
    // Returns 0 in normal.
    int display() {
        show_splitline();
        for (const auto& cell : root["cells"].array_range()) {
            display_cell(cell);
            show_splitline();
        }
        return 0;
    }

private:
    const jsoncons::json &root;
    std::ostream &str;
    const int pad_width;
    bool align;
    std::string padding;

    /* bool is_python(jsoncons::json const &j) { */
    /*     const auto &j2 = j.at_or_null( */
    /*             "metadata").at_or_null( */
    /*                 "kernelspec").at_or_null( */
    /*                     "language"); */
    /*     if (j2.is_null()) return false; */
    /*     if (j2.as<std::string>() == "python") return true; */
    /*     else return false; */
    /* } */

    static inline std::string pad_n(int n) { return std::string(n, ' '); }

    // Main body
    void display_cell(jsoncons::json const &cell) {
        bool pad_flag = false;

        std::string cell_type = cell["cell_type"].as<std::string>();
        if (cell_type == "raw")
            show_header("raw");
        else if (cell_type == "code")
            show_input_count(cell["execution_count"]);
        else if (cell_type == "markdown")
            show_header("markdown");
        else 
            return;

        for (const auto &source_text : cell["source"].array_range()) {
            if (pad_flag) str << padding;
            else pad_flag = true;
            str << source_text.as<std::string>();
        }
        str << std::endl;

        if (!cell.contains("outputs") || cell["outputs"].empty()) return;
        show_sub_splitline();

        pad_flag = false;
        bool out_flag = true;
        for (const auto &output : cell["outputs"].array_range()) {
            std::string output_type = output["output_type"].as<std::string>();
            if (output_type == "stream") {
                show_header(output["name"].as<std::string>());
                show_textplain(output["text"], false);
                pad_flag = true;
            } else if (output_type == "execute_result") {
                if (out_flag) {
                    show_output_count(cell["execution_count"]);
                    out_flag = false;
                    pad_flag = false;
                }
                show_textplain(output["data"]["text/plain"], pad_flag);
            } else {
                show_discard(output);
            }
            str << std::endl;
        }
    }

    void show_header(std::string hdr) {
        hdr = "`" + hdr + "`";
        int left = (pad_width - hdr.size()) / 2;
        if (align)
            str << COMMENT << hdr << std::endl;
        else
            str << pad_n(left) << hdr << pad_n(pad_width - left - hdr.size());
    }

    void show_splitline() {
        str << padding << 
            "========================================"
            "=================================" << std::endl;
    }

    void show_sub_splitline() {
        str << padding << 
            "----------------------------------------"
            "---------------------------------" << std::endl;
    }

    // Display `In [...]`
    void show_input_count(jsoncons::json j) {
        std::string num_str = j.is_null() ? " " : std::to_string(j.as<int>());
        std::string out = "In [" + num_str + "]: ";
        if (align)
            str << COMMENT << out << std::endl;
        else
            str << pad_n(pad_width - out.size()) << out;
    }

    // Display `Out [...]`
    void show_output_count(jsoncons::json j) {
        std::string num_str = std::to_string(j.as<int>());
        std::string out = "Out[" + num_str + "]: ";
        if (align)
            str << COMMENT << out << std::endl;
        else
            str << pad_n(pad_width - out.size()) << out;
    }

    // Display texts/codes
    void show_textplain(jsoncons::json texts, bool pad_flag) {
        for (auto const &text : texts.array_range()) {
            if (pad_flag) str << padding;
            else pad_flag = true;
            str  << text.as<std::string>();
        }
    }

    // Display discard message on unsupport data, e.g. images
    void show_discard(jsoncons::json j) {
        jsoncons::json text = j.at_or_null("data").at_or_null("text/plain");
        if (text.is_null())
            str << padding << "`discard output_type: " 
                << j["output_type"] << "`";
        else
            str << padding << text.as<std::string>();
    }
};

void display_usage_and_exit(bool normal = false) {
    std::cerr 
        << "Usage: jcat FILE [OPTION]\n\n"
        << "FILE:\tA json parsable notebook file (*.ipynb).\n\n"
        << "OPTION:\n"
        << "  -a:\tAlign prompt (In/Out) for copy.\n";

    if (normal) exit(EXIT_SUCCESS);
    else exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) {
    std::string fname;
    bool align_promp = false;
    if (argc == 2) {
        ;
    } else if (argc == 3) {
        if (std::string(argv[2]) != "-a")
            display_usage_and_exit();
        align_promp = true;
    } else
        display_usage_and_exit();

    fname = std::string(argv[1]);

    std::ifstream ifs(fname, std::ios::in);
    if (!ifs.good()) {
        std::cerr << fname << " does not exists." << std::endl;
        display_usage_and_exit();
    }
    std::stringstream buf;
    buf << ifs.rdbuf(); // content available as buf.str()

    const jsoncons::json &nb = [&]() -> jsoncons::json {
        JSONCONS_TRY {
            return jsoncons::json::parse(buf.str());
        } JSONCONS_CATCH (
                const jsoncons::ser_error &e) {
            std::cerr << e.what() << std::endl;
            exit(EXIT_FAILURE);
        }
    }();
    Jcat jcat_obj(nb, std::cout, align_promp, PAD);
    if (jcat_obj.display() < 0)
        std::cerr 
            << fname 
            << ": Some errors have occurred, exit." 
            << std::endl;

    ifs.close();
    return 0;
}
