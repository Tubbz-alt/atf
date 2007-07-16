#
# Automated Testing Framework (atf)
#
# Copyright (c) 2007 The NetBSD Foundation, Inc.
# All rights reserved.
#
# This code is derived from software contributed to The NetBSD Foundation
# by Julio M. Merino Vidal, developed as part of Google's Summer of Code
# 2007 program.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this
#    software must display the following acknowledgement:
#        This product includes software developed by the NetBSD
#        Foundation, Inc. and its contributors.
# 4. Neither the name of The NetBSD Foundation nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND
# CONTRIBUTORS ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# TODO: Do the same tests but for programs written in C++.

create_files()
{
    mkdir tmp
    touch tmp/datafile

    cat >tmp/tp.sh <<EOF
exists_head() {
    atf_set "descr" "Not important"
}
exists_body() {
    test -f \$(atf_get srcdir)/datafile || atf_fail "Cannot find datafile"
}

atf_init_test_cases() {
    atf_add_test_case exists
}
EOF

    atf_check 'atf-compile -o tmp/tp tmp/tp.sh' 0 null null

    # The following is a hack to workaround the libtool scripts.  Ideally
    # we'd copy h_srcdir_cpp into the tmp directory and run it from there,
    # but that fails miserably when the binary is one of the scripts
    # generated by libtool (i.e. when running the tests from the source
    # directory).
    touch tmp/h_srcdir_cpp
}

default_head()
{
    atf_set "descr" "Checks that the program can find its files if" \
                    "executed from the same directory"
}
default_body()
{
    create_files

    # Test the shell interface.
    atf_check 'cd tmp && ./tp' 0 ignore null
    atf_check './tmp/tp' 1 null stderr
    atf_check 'grep "Cannot.*find.*source.*directory" stderr' 0 ignore null

    # Test the C++ interface.
    atf_check "cd tmp && $(atf_get srcdir)/h_srcdir_cpp" 0 ignore null
    atf_check "$(atf_get srcdir)/h_srcdir_cpp" 1 null stderr
    atf_check 'grep "Cannot.*find.*source.*directory" stderr' 0 ignore null
}

sflag_head()
{
    atf_set "descr" "Checks that the program can find its files when" \
                    "using the -s flag"
}
sflag_body()
{
    create_files

    # XXX Shouldn't have to use absolute pathnames for -s.  Fix this.

    # Test the shell interface.
    atf_check 'cd tmp && ./tp -s $(pwd)' 0 ignore null
    atf_check './tmp/tp' 1 null stderr
    atf_check 'grep "Cannot.*find.*source.*directory" stderr' 0 ignore null
    atf_check './tmp/tp -s $(pwd)/tmp' 0 ignore null

    # Test the C++ interface.
    atf_check "cd tmp && $(atf_get srcdir)/h_srcdir_cpp -s $(pwd)/tmp" \
              0 ignore null
    atf_check "$(atf_get srcdir)/h_srcdir_cpp" 1 null stderr
    atf_check 'grep "Cannot.*find.*source.*directory" stderr' 0 ignore null
    atf_check "$(atf_get srcdir)/h_srcdir_cpp -s $(pwd)/tmp" 0 ignore null
}

atf_init_test_cases()
{
    atf_add_test_case default
    atf_add_test_case sflag
}

# vim: syntax=sh:expandtab:shiftwidth=4:softtabstop=4
