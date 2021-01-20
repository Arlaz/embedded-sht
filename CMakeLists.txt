set(sht_sensor "sht3x")

idf_component_register(
        SRCS
            ${sht_sensor}/sht3x.c
            embedded-common/common/sensirion_common.c
            embedded-common/i2c/sensirion_i2c.c
            embedded-common/i2c/sample-implementations/esp32/sensirion_i2c_hal.c

        INCLUDE_DIRS
            ${sht_sensor}
            sht-common
            embedded-common/common
            embedded-common/i2c
)