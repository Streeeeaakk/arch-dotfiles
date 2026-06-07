#include <security/pam_appl.h>
#include <security/pam_misc.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static char password[512];

static int conv_func(int num_msg, const struct pam_message **msg,
                     struct pam_response **resp, void *appdata_ptr) {
    struct pam_response *responses = calloc(num_msg, sizeof(struct pam_response));
    if (!responses) return PAM_CONV_ERR;

    for (int i = 0; i < num_msg; i++) {
        if (msg[i]->msg_style == PAM_PROMPT_ECHO_OFF ||
            msg[i]->msg_style == PAM_PROMPT_ECHO_ON) {
            responses[i].resp = strdup(password);
            responses[i].resp_retcode = 0;
        } else {
            responses[i].resp = NULL;
            responses[i].resp_retcode = 0;
        }
    }

    *resp = responses;
    return PAM_SUCCESS;
}

int main(void) {
    const char *user = getenv("USER");
    if (!user || strlen(user) == 0) {
        fprintf(stderr, "No USER env\n");
        return 2;
    }

    if (!fgets(password, sizeof(password), stdin)) {
        fprintf(stderr, "No password input\n");
        return 2;
    }

    password[strcspn(password, "\n")] = '\0';

    struct pam_conv conv = {
        conv_func,
        NULL
    };

    pam_handle_t *pamh = NULL;

    int ret = pam_start("login", user, &conv, &pamh);
    if (ret != PAM_SUCCESS) {
        fprintf(stderr, "pam_start failed\n");
        return 3;
    }

    ret = pam_authenticate(pamh, 0);

    if (ret == PAM_SUCCESS) {
        ret = pam_acct_mgmt(pamh, 0);
    }

    pam_end(pamh, ret);

    memset(password, 0, sizeof(password));

    if (ret == PAM_SUCCESS) {
        puts("OK");
        return 0;
    }

    puts("FAIL");
    return 1;
}
