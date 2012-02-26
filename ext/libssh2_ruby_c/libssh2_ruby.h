#ifndef LIBSSH2_RUBY_H
#define LIBSSH2_RUBY_H

#include <ruby.h>
#include <libssh2.h>

/*
 * Makes the otherwise non-blocking libssh2 method call
 * a blocking call by waiting for it.
 * */
#define BLOCK(stmt) while ((stmt) == LIBSSH2_ERROR_EAGAIN)

/*
 * Verifies the given argument is a valid session. This is called a lot
 * so I macro-fied it.
 * */
#define CHECK_SESSION(session) do{\
    if (!rb_obj_is_kind_of(session, rb_cLibSSH2_Native_Session))\
        rb_raise(rb_eArgError, "session must be a native session type");\
} while (0)

extern VALUE rb_mLibSSH2;
extern VALUE rb_mLibSSH2_Native;
extern VALUE rb_eLibSSH2_Native_Error;
extern VALUE rb_cLibSSH2_Native_Session;

/*
 * The struct embedded with LibSSH2::Native::Session classes
 * to store our internal C data.
 * */
typedef struct {
    LIBSSH2_SESSION *session;
} LibSSH2_Ruby_Session;

void init_libssh2_error();
void init_libssh2_global();
void init_libssh2_session();

VALUE libssh2_ruby_wrap_error(int);

#endif
