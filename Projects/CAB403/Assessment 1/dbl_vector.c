#include <stdio.h>
#include <stdlib.h>
#include "dbl_vector.h"

void dv_init(dbl_vector_t *vec)
{
    vec->capacity = DV_INITIAL_CAPACITY;
    vec->size = 0;
    vec->data = malloc(vec->capacity * sizeof(double));
}

void dv_ensure_capacity(dbl_vector_t *vec, size_t new_size)
{
    size_t old_size = vec->size;
    size_t old_capacity = vec->capacity;
    double *old_data = vec->data;
    size_t new_capacity = fmax(old_capacity * DV_GROWTH_FACTOR, new_size);
    if (new_size <= old_capacity)
    {
        vec->capacity = old_capacity;
        vec->data = old_data;
    }
    else
    {
        vec->capacity = new_capacity;
        vec->data = realloc(old_data, vec->capacity * sizeof(double));
    }
}

void dv_destroy(dbl_vector_t *vec)
{
    vec->capacity = 0;
    vec->size = 0;
    free(vec->data);
    vec->data = NULL;
}

void dv_copy(dbl_vector_t *vec, dbl_vector_t *dest)
{
    dest->size = vec->size;
    dv_ensure_capacity(dest, vec->size);
    for (size_t i = 0; i < vec->size; ++i)
    {
        dest->data[i] = vec->data[i];
    }
}

void dv_clear(dbl_vector_t *vec)
{
    vec->size = 0;
}

void dv_push(dbl_vector_t *vec, double new_item)
{
    size_t old_size = vec->size;
    size_t old_capacity = vec->capacity;
    double *old_data = vec->data;
    dv_ensure_capacity(vec, old_size + 1);
    for (size_t i = 0; i < old_size; ++i)
    {
        old_data[i] = vec->data[i];
    }
    vec->data[old_size] = new_item;
    vec->size = old_size + 1;
}

void dv_pop(dbl_vector_t *vec)
{
    size_t old_size = vec->size;
    size_t old_capacity = vec->capacity;
    double *old_data = vec->data;
    vec->capacity = old_capacity;
    vec->data = old_data;
    if (old_size > 0)
    {
        vec->size = old_size - 1;
        for (size_t i = 0; i < old_size - 1; ++i)
        {
            vec->data[i] = old_data[i];
        }
    }
    else
    {
        vec->size = 0;
    }
}

double dv_last(dbl_vector_t *vec)
{
    double result = NAN;
    size_t old_size = vec->size;
    size_t old_capacity = vec->capacity;
    double *old_data = vec->data;
    vec->size = old_size;
    vec->capacity = old_capacity;
    vec->data = old_data;
    for (size_t i = 0; i < vec->size; ++i)
    {
        vec->data[i] = old_data[i];
    }
    if (vec->size > 0)
    {
        return vec->data[vec->size - 1];
    }
    else
    {
        return NAN;
    }
    return result;
}

void dv_insert_at(dbl_vector_t *vec, size_t pos, double new_item)
{
    size_t old_size = vec->size;
    double *old_data = vec->data;
    size_t loc = fmin(pos, old_size);
    vec->size = old_size + 1;
    dv_ensure_capacity(vec, old_size + 1);
    for (size_t i = 0; i < loc; ++i)
    {
        old_data[i] = vec->data[i];
    }
    for (size_t i = old_size; i > loc; --i)
    {
        vec->data[i] = old_data[i - 1];
    }
    vec->data[loc] = new_item;
}

void dv_remove_at(dbl_vector_t *vec, size_t pos)
{
    size_t old_size = vec->size;
    double *old_data = vec->data;
    size_t loc = fmin(pos, old_size);
    for (size_t i = 0; i < loc; ++i)
    {
        old_data[i] = vec->data[i];
    }
    for (size_t i = loc; i < vec->size; ++i)
    {
        vec->data[i] = old_data[i + 1];
    }
    if (pos > old_size)
    {
        old_size = vec->size;
    }
    else
    {
        vec->size = old_size - 1;
    }
}

void dv_foreach(dbl_vector_t *vec, void (*callback)(double, void *), void *info)
{
    size_t old_size = vec->size;
    size_t old_capacity = vec->capacity;
    double *old_data = vec->data;
    vec->capacity = old_capacity;
    vec->size = old_size;
    vec->data = old_data;
    for (size_t i = 0; i < vec->size; ++i)
    {
        callback(vec->data[i], info);
    }
}