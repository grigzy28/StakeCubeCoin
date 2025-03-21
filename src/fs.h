// Copyright (c) 2017 The Bitcoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef BITCOIN_FS_H
#define BITCOIN_FS_H

#include <stdio.h>
#include <string>
#if defined WIN32 && defined __GLIBCXX__
#include <ext/stdio_filebuf.h>
#endif

#include <filesystem>

//#include <boost/filesystem.hpp>
//#include <boost/filesystem/fstream.hpp>

/** Filesystem operations and types */
namespace fs
// = boost::filesystem;
{

using namespace std::filesystem;

/**
 * Path class wrapper to block calls to the fs::path(std::string) implicit
 * constructor and the fs::path::string() method, which have unsafe and
 * unpredictable behavior on Windows (see implementation note in
 * \ref PathToString for details)
 */
class path : public std::filesystem::path
{
public:
    using std::filesystem::path::path;

    // Allow path objects arguments for compatibility.
    path(std::filesystem::path path) : std::filesystem::path::path(std::move(path)) {}
    path& operator=(std::filesystem::path path) { std::filesystem::path::operator=(std::move(path)); return *this; }
    path& operator/=(std::filesystem::path path) { std::filesystem::path::operator/=(std::move(path)); return *this; }

    // Allow literal string arguments, which are safe as long as the literals are ASCII.
    path(const char* c) : std::filesystem::path(c) {}
    path& operator=(const char* c) { std::filesystem::path::operator=(c); return *this; }
    path& operator/=(const char* c) { std::filesystem::path::operator/=(c); return *this; }
    path& append(const char* c) { std::filesystem::path::append(c); return *this; }

    // Disallow std::string arguments to avoid locale-dependent decoding on windows.
    path(std::string) = delete;
    path& operator=(std::string) = delete;
    path& operator/=(std::string) = delete;
    path& append(std::string) = delete;

    // Disallow std::string conversion method to avoid locale-dependent encoding on windows.
    std::string string() const = delete;

    std::string u8string() const
    {
        const auto& utf8_str{std::filesystem::path::u8string()};
        // utf8_str might either be std::string (C++17) or std::u8string
        // (C++20). Convert both to std::string. This method can be removed
        // after switching to C++20.
        return std::string{utf8_str.begin(), utf8_str.end()};
    }

    // Required for path overloads in <fstream>.
    // See https://gcc.gnu.org/git/?p=gcc.git;a=commit;h=96e0367ead5d8dcac3bec2865582e76e2fbab190
    path& make_preferred() { std::filesystem::path::make_preferred(); return *this; }
    path filename() const { return std::filesystem::path::filename(); }
};

/** Bridge operations to C stdio */
namespace fsbridge {
    FILE *fopen(const fs::path& p, const char *mode);

    /**
     * Helper function for joining two paths
     *
     * @param[in] base  Base path
     * @param[in] path  Path to combine with base
     * @returns path unchanged if it is an absolute path, otherwise returns base joined with path. Returns base unchanged if path is empty.
     * @pre  Base path must be absolute
     * @post Returned path will always be absolute
     */
    fs::path AbsPathJoin(const fs::path& base, const fs::path& path);

    class FileLock
    {
    public:
        FileLock() = delete;
        FileLock(const FileLock&) = delete;
        FileLock(FileLock&&) = delete;
        explicit FileLock(const fs::path& file);
        ~FileLock();
        bool TryLock();
        std::string GetReason() { return reason; }

    private:
        std::string reason;
#ifndef WIN32
        int fd = -1;
#else
        void* hFile = (void*)-1; // INVALID_HANDLE_VALUE
#endif
    };

    std::string get_filesystem_error_message(const fs::filesystem_error& e);
};

#endif // BITCOIN_FS_H
