#include <libssh2_ruby.h>

/*
 * Helper to return the LIBSSH2_SESSION pointer for the given
 * instance.
 * */
static inline LIBSSH2_SESSION *
get_session(VALUE self) {
    LibSSH2_Ruby_Session *session;
    Data_Get_Struct(self, LibSSH2_Ruby_Session, session);
    return session->session;
}

/*
 * Called when the object is deallocated in order to deallocate the
 * interal state.
 * */
static void
session_dealloc(LibSSH2_Ruby_Session *session) {
    if (session->session != NULL) {
        BLOCK(libssh2_session_free(session->session));
    }

    free(session);
}

/*
 * Called to allocate the memory associated with the object. We allocate
 * memory for internal structs and set them onto the object.
 * */
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

/*
 * call-seq:
 *     session.handshake(socket.fileno) -> int
 *
 * Initiates the handshake sequence for this session. You must
 * pass in the file number for the socket to use. This wll return
 * 0 on success, or raise an exception otherwise.
 *
 * */
static VALUE
handshake(VALUE self, VALUE num_fd) {
    int fd = NUM2INT(num_fd);
    int ret = libssh2_session_handshake(get_session(self), fd);

    if (ret == 0 || ret == LIBSSH2_ERROR_EAGAIN)
        return INT2FIX(ret);

    // XXX: Exception
    return INT2FIX(ret);
}

/*
 * call-seq:
 *     session.set_blocking(true) -> true
 *
 * If the argument is true, enables blocking semantics for this session,
 * otherwise enables non-blocking semantics.
 *
 * */
static VALUE
set_blocking(VALUE self, VALUE blocking) {
    int blocking_arg = blocking == Qtrue ? 1 : 0;
    libssh2_session_set_blocking(get_session(self), blocking_arg);
    return blocking;
}

void init_libssh2_session() {
    VALUE cSession = rb_cLibSSH2_Native_Session;
    rb_define_alloc_func(cSession, allocate);
    rb_define_method(cSession, "initialize", initialize, 0);
    rb_define_method(cSession, "handshake", handshake, 1);
    rb_define_method(cSession, "set_blocking", set_blocking, 1);
}
