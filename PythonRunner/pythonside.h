#ifndef WFC_PRUNNER_PYTHON_SIDE
#define WFC_PRUNNER_PYTHON_SIDE 1

typedef void (*output_callback_t)(const char*);

int pside_run_code(output_callback_t);

#endif /* ifndef WFC_PRUNNER_PYTHON_SIDE */
