#include <libssh2_ruby.h>

/*
 * call-seq:
 *     LibSSH2::Native.version -> string
 *
 * Returns the version of libssh2 that is running.
 *
 * */
static VALUE
version(VALUE module) {
    VALUE result = rb_cNilClass;
    const char *version_string = libssh2_version(0);

    // Technically `libssh2_version` can return NULL if the runtime
    // version is not new enough, but the "0" parameter above should
    // force this to always be true. Still, better safe than segfault.
    if (version_string != NULL) {
        result = rb_str_new_cstr(version_string);
    }

    return result;
}

void init_libssh2_global() {
    rb_define_singleton_method(mLibSSH2_Native, "version", version, 0);
}
