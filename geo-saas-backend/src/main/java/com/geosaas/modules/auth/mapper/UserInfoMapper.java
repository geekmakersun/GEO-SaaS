package com.geosaas.modules.auth.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.geosaas.modules.auth.entity.UserInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface UserInfoMapper extends BaseMapper<UserInfo> {

    @Select("SELECT * FROM user_info WHERE username = #{username} AND deleted = 0")
    UserInfo selectByUsername(String username);
}