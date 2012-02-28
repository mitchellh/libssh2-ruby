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

/*
 * Macro that handles generic libssh2 return values as we normally
 * do throughout the library: return true for success, and raise an
 * exception for any errors.
 * */
#define HANDLE_LIBSSH2_RESULT(value) do{\
    if (value == 0)\
        return Qtrue;\
    rb_exc_raise(libssh2_ruby_wrap_error(value));\
    return Qnil;\
} while (0)

extern VALUE rb_mLibSSH2;
extern VALUE rb_mLibSSH2_Native;
extern VALUE rb_mLibSSH2_Native_Error;
extern VALUE rb_cLibSSH2_Native_Channel;
extern VALUE rb_cLibSSH2_Native_Session;

/*
 * The struct embedded with LibSSH2::Native::Session classes
 * to store our internal C data.
 * */
typedef struct {
    LIBSSH2_SESSION *session;
    int refcount;
} LibSSH2_Ruby_Session;

/*
 * The struct embedded with LibSSH2::Native::Channel classes.
 * */
typedef struct {
    LIBSSH2_CHANNEL *channel;
    LibSSH2_Ruby_Session *session;
} LibSSH2_Ruby_Channel;

void init_libssh2_error();
void init_libssh2_global();
void init_libssh2_channel();
void init_libssh2_session();

void libssh2_ruby_session_retain(LibSSH2_Ruby_Session *);
void libssh2_ruby_session_release(LibSSH2_Ruby_Session *);

VALUE libssh2_ruby_wrap_error(int);

#endif
