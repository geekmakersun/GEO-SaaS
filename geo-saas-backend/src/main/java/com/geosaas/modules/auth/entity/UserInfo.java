package com.geosaas.modules.auth.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.geosaas.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("user_info")
public class UserInfo extends BaseEntity {

    private String username;

    private String password;

    private String nickname;

    private String email;

    private String phone;

    private String avatar;

    private String role;

    private Integer status;
}