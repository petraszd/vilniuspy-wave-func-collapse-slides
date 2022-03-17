#include <gdnative_api_struct.gen.h>

#include <string.h>
#include <assert.h>
#include "gdnative/array.h"
#include "pythonside.h"

#define GD_DEBUG(p_str) {                            \
    const char* p_str2 = (p_str);                    \
    godot_string str;                                \
    api->godot_string_new(&str);                     \
    api->godot_string_parse_utf8(&str, p_str2);      \
    api->godot_print(&str);                          \
    api->godot_string_destroy(&str);                 \
}

const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_nativescript_api_struct *ns_api = NULL;


void* prunner_constructor(godot_object* p_instance, void* p_method_data);
void prunner_destructor(godot_object* p_instance, void* p_method_data, void* p_user_data);

godot_variant prunner_run(
        godot_object* p_instance,
        void* p_method_data,
        void* p_user_data,
        int p_num_args,
        godot_variant** p_args);

void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options* p_options)
{
    api = p_options->api_struct;
    for (size_t i = 0; i < api->num_extensions; ++i) {
        if (api->extensions[i]->type == GDNATIVE_EXT_NATIVESCRIPT) {
            ns_api = (godot_gdnative_ext_nativescript_api_struct*)api->extensions[i];
            break;
        }
    }
}

void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options* p_options)
{
    api = NULL;
    ns_api = NULL;
}

void GDN_EXPORT godot_nativescript_init(void* p_handle)
{
    godot_instance_create_func create = {
        .create_func = &prunner_constructor,
        .free_func = NULL,
        .method_data = NULL,
    };
    godot_instance_destroy_func destroy = {
        .destroy_func = &prunner_destructor,
        .free_func = NULL,
        .method_data = NULL,
    };
    ns_api->godot_nativescript_register_class(
            p_handle, "PYTHON_RUNNER", "Reference",
            create, destroy);

    godot_instance_method get_foobar = {
        .method = &prunner_run,
        .method_data = NULL,
        .free_func = NULL,
    };
    godot_method_attributes atts = { GODOT_METHOD_RPC_MODE_DISABLED };
    ns_api->godot_nativescript_register_method(
            p_handle, "PYTHON_RUNNER", "run",
            atts, get_foobar);
}

typedef struct {
    godot_pool_string_array python_stdout;
    godot_pool_string_array python_stderr;
    godot_pool_int_array selections;
} prunner_user_data_t;

void* prunner_constructor(godot_object* p_instance, void* p_method_data)
{
    prunner_user_data_t* user_data = api->godot_alloc(sizeof(prunner_user_data_t));

    api->godot_pool_string_array_new(&user_data->python_stdout);
    api->godot_pool_string_array_new(&user_data->python_stderr);
    api->godot_pool_int_array_new(&user_data->selections);

    return user_data;
}

void prunner_destructor(godot_object* p_instance, void* p_method_data, void* p_user_data)
{
    prunner_user_data_t *user_data = p_user_data;

    api->godot_pool_string_array_destroy(&user_data->python_stdout);
    api->godot_pool_string_array_destroy(&user_data->python_stderr);
    api->godot_pool_int_array_destroy(&user_data->selections);
    // TODO: make sure that you do not need to destroy each element

    api->godot_free(p_user_data);
}

void prunner_stdout_callback(void* p_user_data, const char* p_stdout_str)
{
    prunner_user_data_t* user_data = p_user_data;

    godot_string str;
    api->godot_string_new(&str);
    api->godot_string_parse_utf8(&str, p_stdout_str);
    api->godot_pool_string_array_append(&user_data->python_stdout, &str);
    api->godot_string_destroy(&str);
}

void prunner_stderr_callback(void* p_user_data, const char* p_stderr_str)
{
    prunner_user_data_t* user_data = p_user_data;

    godot_string str;
    api->godot_string_new(&str);
    api->godot_string_parse_utf8(&str, p_stderr_str);
    api->godot_pool_string_array_append(&user_data->python_stderr, &str);
    api->godot_string_destroy(&str);
}

void prunner_result_callback(void* p_user_data, int* result_items, int num_result_items)
{
    prunner_user_data_t* user_data = p_user_data;
    for (int i = 0; i < num_result_items; ++i) {
        api->godot_pool_int_array_append(&user_data->selections, result_items[i]);
    }
}

godot_variant prunner_run(
        godot_object* p_instance,
        void* p_method_data,
        void* p_user_data,
        int p_num_args,
        godot_variant** p_args)
{
    GD_DEBUG("-- MACRO: Start --");

    prunner_user_data_t* user_data = p_user_data;

    /* Reset state */
    api->godot_pool_string_array_resize(&user_data->python_stdout, 0);
    api->godot_pool_string_array_resize(&user_data->python_stderr, 0);
    api->godot_pool_int_array_resize(&user_data->selections, 0);
    // TODO: make sure it is enough to free memory

    /* Extract args */
    assert(p_num_args == 5);

    godot_string code_str = api->godot_variant_as_string(p_args[0]);
    godot_char_string code_char_str = api->godot_string_utf8(&code_str);
    api->godot_string_destroy(&code_str);

    function_args_t function_args;
    function_args.code_len = api->godot_char_string_length(&code_char_str);
    function_args.code = api->godot_char_string_get_data(&code_char_str);
    function_args.num_cols = (int)(api->godot_variant_as_int(p_args[1]));
    function_args.num_rows = (int)(api->godot_variant_as_int(p_args[2]));
    function_args.num_image_fragments = (int)(api->godot_variant_as_int(p_args[3]));

    godot_array compatibilities_arg = api->godot_variant_as_array(p_args[4]);
    function_args.num_compatibilities = (int)(api->godot_array_size(&compatibilities_arg));
    int compatibilities[function_args.num_compatibilities];
    for (int i = 0; i < function_args.num_compatibilities; ++i) {
        godot_variant item = api->godot_array_get(&compatibilities_arg, i);
        compatibilities[i] = api->godot_variant_as_int(&item);
        api->godot_variant_destroy(&item);
    }
    function_args.compatibilities = compatibilities;

    /* Run */
    if (pside_run_code(
                p_user_data,
                &prunner_stdout_callback,
                &prunner_stderr_callback,
                &prunner_result_callback,
                &function_args) != 0)
    {
        GD_DEBUG("ERROR: while running Python code");
    }

    api->godot_array_destroy(&compatibilities_arg);
    api->godot_char_string_destroy(&code_char_str);

    /* Return */
    godot_variant ret;
    godot_variant stdout;
    godot_variant stderr;
    godot_variant selections;
    godot_array arr;

    api->godot_array_new(&arr);

    api->godot_variant_new_pool_string_array(&stdout, &user_data->python_stdout);
    api->godot_array_append(&arr, &stdout);
    api->godot_variant_destroy(&stdout);

    api->godot_variant_new_pool_string_array(&stderr, &user_data->python_stderr);
    api->godot_array_append(&arr, &stderr);
    api->godot_variant_destroy(&stderr);

    api->godot_variant_new_pool_int_array(&selections, &user_data->selections);
    api->godot_array_append(&arr, &selections);
    api->godot_variant_destroy(&selections);

    api->godot_variant_new_array(&ret, &arr);
    api->godot_array_destroy(&arr);

    GD_DEBUG("-- MACRO: EnD --");
    return ret;
}
