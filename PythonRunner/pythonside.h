#ifndef WFC_PRUNNER_PYTHON_SIDE
#define WFC_PRUNNER_PYTHON_SIDE 1

typedef void (*output_callback_t)(void*, const char*);
typedef void (*result_callback_t)(void*, int*, int);

typedef struct {
    void* user_data;
    output_callback_t callback;
} output_module_state_t;

typedef struct {
    int num_cols;
    int num_rows;
    int num_image_fragments;
    int* compatibilities;
    int  num_compatibilities;
} function_args_t;

int pside_run_code(
        void* p_user_data,
        output_callback_t p_stdout_callback,
        output_callback_t p_stderr_callback,
        result_callback_t p_result_callback,
        function_args_t* p_function_args);

#endif /* ifndef WFC_PRUNNER_PYTHON_SIDE */
