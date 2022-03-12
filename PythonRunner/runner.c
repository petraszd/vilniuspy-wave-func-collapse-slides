#include <gdnative_api_struct.gen.h>

#include <string.h>
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
} prunner_user_data_t;

void* prunner_constructor(godot_object* p_instance, void* p_method_data)
{
    prunner_user_data_t* user_data = api->godot_alloc(sizeof(prunner_user_data_t));

    api->godot_pool_string_array_new(&user_data->python_stdout);
    api->godot_pool_string_array_new(&user_data->python_stderr);

    return user_data;
}

void prunner_destructor(godot_object* p_instance, void* p_method_data, void* p_user_data)
{
    prunner_user_data_t *user_data = p_user_data;

    api->godot_pool_string_array_destroy(&user_data->python_stdout);
    api->godot_pool_string_array_destroy(&user_data->python_stderr);
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

// TODO: rename
godot_variant prunner_run(
        godot_object* p_instance,
        void* p_method_data,
        void* p_user_data,
        int p_num_args,
        godot_variant** p_args)
{
    GD_DEBUG("-- MACRO: Start --");

    prunner_user_data_t* user_data = p_user_data;
    // TOOD: clear stdout, and stderr

    if (pside_run_code(
                p_user_data,
                &prunner_stdout_callback,
                &prunner_stderr_callback) != 0)
    {
        GD_DEBUG("ERROR: while running Python code");
    }
    GD_DEBUG("-- MACRO: EnD --");

    godot_variant ret;
    godot_variant stdout;
    godot_variant stderr;
    godot_array arr;

    api->godot_array_new(&arr);

    api->godot_variant_new_pool_string_array(&stdout, &user_data->python_stdout);
    api->godot_array_append(&arr, &stdout);
    api->godot_variant_destroy(&stdout);

    api->godot_variant_new_pool_string_array(&stderr, &user_data->python_stderr);
    api->godot_array_append(&arr, &stderr);
    api->godot_variant_destroy(&stderr);

    api->godot_variant_new_array(&ret, &arr);
    api->godot_array_destroy(&arr);

    /*api->godot_variant_new_pool_string_array(&ret, user_data->python_stdout);*/
    return ret;
}
