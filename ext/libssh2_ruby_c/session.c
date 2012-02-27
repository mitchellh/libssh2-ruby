#include <libssh2_ruby.h>

/*
 * Increases the reference counter on the ruby session container.
 * */
void
libssh2_ruby_session_retain(LibSSH2_Ruby_Session *session_data) {
    session_data->refcount++;
}

/*
 * Decrements the reference counter on the ruby session container.
 * When this goes to 0 then the session will be released.
 * */
void
libssh2_ruby_session_release(LibSSH2_Ruby_Session *session_data) {
    // Decrease the reference count
    session_data->refcount--;

    // If the reference count is 0, free all the things!
    if (session_data->refcount == 0) {
        if (session_data->session != NULL) {
            BLOCK(libssh2_session_disconnect(
                        session_data->session,
                        "Normal shutdown by libssh2-ruby."));
            BLOCK(libssh2_session_free(session_data->session));
        }

        free(session_data);
    }
}

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
session_dealloc(LibSSH2_Ruby_Session *session_data) {
    libssh2_ruby_session_release(session_data);
}

/*
 * Called to allocate the memory associated with the object. We allocate
 * memory for internal structs and set them onto the object.
 * */
static VALUE
allocate(VALUE self) {
    LibSSH2_Ruby_Session *session = malloc(sizeof(LibSSH2_Ruby_Session));
    session->session  = NULL;
    session->refcount = 0;

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

    // Retain so that we have a proper refcount
    libssh2_ruby_session_retain(session);

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
    HANDLE_LIBSSH2_RESULT(ret);
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

/*
 * call-seq:
 *     session.userauth_authenticated -> true/false
 *
 * Returns a boolean of whether this session has been authenticated or
 * not.
 *
 * */
static VALUE
userauth_authenticated(VALUE self) {
    return libssh2_userauth_authenticated(get_session(self)) == 1 ?
        Qtrue :
        Qfalse;
}

/*
 * call-seq:
 *     session.userauth_password("username", "password")
 *
 * Attempts to authenticate using a username and password.
 *
 * */
static VALUE
userauth_password(VALUE self, VALUE username, VALUE password) {
    int result;
    rb_check_type(username, T_STRING);
    rb_check_type(password, T_STRING);

    result = libssh2_userauth_password(
            get_session(self),
            StringValuePtr(username),
            StringValuePtr(password));
    HANDLE_LIBSSH2_RESULT(result);
}

/*
 * call-seq:
 *     session.userauth_publickey_fromfile("username", "/etc/key.pub", "/etc/key", "foo")
 *
 * Attempts to authenticate using public and private keys from files.
 *
 * */
static VALUE
userauth_publickey_fromfile(VALUE self,
        VALUE username,
        VALUE publickey_path,
        VALUE privatekey_path,
        VALUE passphrase) {
    int result;
    rb_check_type(username, T_STRING);
    rb_check_type(publickey_path, T_STRING);
    rb_check_type(privatekey_path, T_STRING);
    rb_check_type(passphrase, T_STRING);

    result = libssh2_userauth_publickey_fromfile(
            get_session(self),
            StringValuePtr(username),
            StringValuePtr(publickey_path),
            StringValuePtr(privatekey_path),
            StringValuePtr(passphrase));
    HANDLE_LIBSSH2_RESULT(result);
}

void init_libssh2_session() {
    VALUE cSession = rb_cLibSSH2_Native_Session;
    rb_define_alloc_func(cSession, allocate);
    rb_define_method(cSession, "initialize", initialize, 0);
    rb_define_method(cSession, "handshake", handshake, 1);
    rb_define_method(cSession, "set_blocking", set_blocking, 1);
    rb_define_method(cSession, "userauth_authenticated", userauth_authenticated, 0);
    rb_define_method(cSession, "userauth_password", userauth_password, 2);
    rb_define_method(cSession, "userauth_publickey_fromfile",
            userauth_publickey_fromfile, 4);
}
