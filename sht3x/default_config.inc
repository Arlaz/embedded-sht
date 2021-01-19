sht_driver_dir ?= ..
sensirion_common_dir ?= ${sht_driver_dir}/embedded-common
sht_common_dir ?= ${sht_driver_dir}/sht-common
sht3x_dir ?= ${sht_driver_dir}/sht3x
CONFIG_I2C_TYPE ?= hw_i2c

sw_i2c_impl_dir ?= ${sensirion_common_dir}/i2c/sample-implementations/GPIO_bit_banging
sw_i2c_impl_src ?= ${sw_i2c_impl_dir}/sensirion_i2c_hal.c
hw_i2c_impl_dir ?= ${sensirion_common_dir}/i2c
hw_i2c_impl_src ?= ${hw_i2c_impl_dir}/sensirion_i2c_hal.c

CFLAGS ?= -Os -Wall -fstrict-aliasing -Wstrict-aliasing=1 -Wsign-conversion -fPIC
CFLAGS += -I${sensirion_common_dir}/common -I${sht_common_dir} -I${sht3x_dir} \
          -I${sensirion_common_dir}/${${CONFIG_I2C_TYPE}_impl_dir}


sensirion_common_sources = ${sensirion_common_dir}/common/sensirion_config.h \
                           ${sensirion_common_dir}/i2c/sensirion_i2c.h \
                           ${sensirion_common_dir}/i2c/sensirion_i2c.c \
                           ${sensirion_common_dir}/common/sensirion_common.h \
                           ${sensirion_common_dir}/common/sensirion_common.c

sht_common_sources = ${sht_common_dir}/sht_git_version.h \
                     ${sht_common_dir}/sht_git_version.c

sht3x_sources = ${sensirion_common_sources} ${sht_common_sources} \
                ${sht3x_dir}/sht3x.h ${sht3x_dir}/sht3x.c

hw_i2c_sources = ${hw_i2c_impl_src}
sw_i2c_sources = ${sw_i2c_impl_dir}/sensirion_i2c_gpio.h \
                 ${sw_i2c_impl_dir}/sensirion_i2c_gpio.c \
                 ${sw_i2c_impl_src}
