#include <libssh2_ruby.h>

static void
session_dealloc(LibSSH2_Ruby_Session *session) {
    if (session->session != NULL) {
        BLOCK(libssh2_session_free(session->session));
    }

    free(session);
}

static VALUE
allocate(VALUE self) {
    LibSSH2_Ruby_Session *session = malloc(sizeof(LibSSH2_Ruby_Session));
    session->session = NULL;

    return Data_Wrap_Struct(self, 0, session_dealloc, session);
}

/*
 * call-seq:
 *     LibSSH2::Native::Session.new
 *
 * Initializes a new LibSSH2 session. This will raise an exception on
 * failure.
 *
 * */
static VALUE
initialize(VALUE self) {
    LibSSH2_Ruby_Session *session;

    // Get the struct that stores our internal state out. This gets
    // setup in the `alloc` method.
    Data_Get_Struct(self, LibSSH2_Ruby_Session, session);

    session->session = libssh2_session_init();
    if (session->session == NULL) {
        // ERROR! Make better exceptions plz.
        rb_raise(rb_eRuntimeError, "session init failed");
        return Qnil;
    }

    return self;
}

void init_libssh2_session() {
    VALUE cSession = rb_cLibSSH2_Native_Session;
    rb_define_alloc_func(cSession, allocate);
    rb_define_method(cSession, "initialize", initialize, 0);
}
