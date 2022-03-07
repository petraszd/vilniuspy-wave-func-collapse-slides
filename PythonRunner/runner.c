#include <gdnative_api_struct.gen.h>

#include <string.h>

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

godot_variant prunner_get_foobar(
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
        .method = &prunner_get_foobar,
        .method_data = NULL,
        .free_func = NULL,
    };
    godot_method_attributes atts = { GODOT_METHOD_RPC_MODE_DISABLED };
    ns_api->godot_nativescript_register_method(
            p_handle, "PYTHON_RUNNER", "get_foobar",
            atts, get_foobar);
}

typedef struct user_data_struct {
    int some_item;
} user_data_struct;

void* prunner_constructor(godot_object* p_instance, void* p_method_data)
{
    user_data_struct *user_data = api->godot_alloc(sizeof(user_data_struct));
    return user_data;
}

void prunner_destructor(godot_object* p_instance, void* p_method_data, void* p_user_data)
{
    // TODO
}

godot_variant prunner_get_foobar(
        godot_object* p_instance,
        void* p_method_data,
        void* p_user_data,
        int p_num_args,
        godot_variant** p_args)
{
    GD_DEBUG("Hello Macro")
    godot_variant ret;
    api->godot_variant_new_nil(&ret);
    return ret;
}
