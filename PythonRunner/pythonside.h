#ifndef WFC_PRUNNER_PYTHON_SIDE
#define WFC_PRUNNER_PYTHON_SIDE 1

typedef void (*output_callback_t)(void*, const char*);

typedef struct {
    void* user_data;
    output_callback_t callback;
} output_module_state_t;

int pside_run_code(
        void* user_data,
        output_callback_t stdout_callback,
        output_callback_t stderr_callback);

#endif /* ifndef WFC_PRUNNER_PYTHON_SIDE */
