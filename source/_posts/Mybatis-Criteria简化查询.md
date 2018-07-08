---
title: Mybatis+Criteria简化查询
date: 2018-07-06 01:01:45
tags:
---

本文是通过mybatis+criteria来简化多条件查询，在使用常规的mybatis时，我们经常碰到的问题就是条件式查询。在一个查询界面，查询条件较多，并且运算符并不总是=时，在后台就需要拼装sql语句。这种处理方式肯定不是使用mybatis的初衷，对于使用了hibernate的我来说，如果mybatis也有一套criteria查询就好了。在具体实现中，我们只需要按照hibernate的处理方式定义好相应的criteria，最后传递给mybatis，其自身处理相应的条件和参数信息，最终返回相应的数据即可。如下一个示例代码所示:

```java
private Criteria buildCriteria(Coupon coupon) {
        Criteria criteria = new Criteria();
    	//等于某个值
        if (StringUtils.isNotEmpty(coupon.getCompanyId())) {
            criteria.andFieldEqualTo("company_id", coupon.getCompanyId());
        }
		//少于某个值
      	criteria.andFieldLessThan("rank_points", coupon.getMaxRankPoints().toString()
        return criteria;
    }
```

如果使用这种方式，无疑会大大降低编写表单式查询的代码复杂度。同时，在内部处理中也不需要作任何判断，而直接将生成的sql交给mybatis去执行即可。当然，我们不希望生成的sql连我们自己都看不懂(想一想hibernate生成的sql),最终生成的sql像下面这样即可。

```sql
select * from table where company_id = #{company_id} and rank_points <= #{rank_points}
```

这是标准的mybatis语句，在进行代码调试和处理时也方便进行查看并处理。那么整个处理逻辑即变成如何处理参数信息，分别处理 **字段名** **运算符** **参数名 字段类型 参数映射**即可。

**模拟hibernate的Criteria类**

```java
/**
 * <pre>
 * 模拟hibernate的Criteria类
 * </pre>
 *
 * @author 李智
 * @version 1.00
 */
public class Criteria {
    //条件集合
    private List<Criterion> criteria;

    public Criteria() {
        criteria = new ArrayList<Criterion>();
    }


    public boolean isValid() {
        return criteria.size() > 0;
    }


    /**
     * 两表链接
     *
     * @param condition
     * @return
     */
    public Criteria andFieldCondition(String condition) {
        addCriterion(condition);
        return this;
    }


    /**
     * 字段为空
     *
     * @param field
     * @return
     */
    public Criteria andFieldIsNull(String field) {
        addCriterion(field + " is null");
        return this;
    }

    /**
     * 字段不为空
     *
     * @param field
     * @return
     */
    public Criteria andFieldIsNotNull(String field) {
        addCriterion(field + " is not null");
        return this;
    }

    /**
     * 字段等于
     *
     * @param field
     * @param value
     * @return
     */
    public Criteria andFieldEqualTo(String field, String value) {
        if (StringUtils.isNotBlank(value)) {
            addCriterion(field + " =", value, field);
        }
        return this;
    }

    /**
     * 字段不等于
     *
     * @param field
     * @param value
     * @return
     */
    public Criteria andFieldNotEqualTo(String field, String value) {
        addCriterion(field + " <>", value, field);
        return this;
    }

    /**
     * 字段值大于
     *
     * @param field
     * @param value
     * @return
     */
    public Criteria andFieldGreaterThan(String field, String value) {
        addCriterion(field + " >", value, field);
        return (Criteria) this;
    }

    /**
     * 字段值大于等于
     *
     * @param field
     * @param value
     * @return
     */
    public Criteria andFieldGreaterThanOrEqualTo(String field, String value) {
        if (StringUtils.isNotBlank(value)) {
            addCriterion(field + " >=", value, field);
        }
        return (Criteria) this;
    }

    public Criteria andTimeFieldBetween(String field, String beginTime, String endTime) {
        if (StringUtils.isNotBlank(beginTime)) {
            addCriterion(field + " >= ", DateUtils.toStoreStr14(beginTime, false), field);
        }
        if (StringUtils.isNotBlank(endTime)) {
            addCriterion(field + " < ", DateUtils.toStoreStr14(endTime, true), field);
        }
        return (Criteria) this;
    }

    public Criteria andDateFieldBetween(String field, String beginDate, String endDate) {
        if (StringUtils.isNotBlank(beginDate)) {
            addCriterion(field + " >= ", beginDate, field);
        }
        if (StringUtils.isNotBlank(endDate)) {
            addCriterion(field + " < ", endDate, field);
        }
        return (Criteria) this;
    }

    /**
     * 字段值小于
     *
     * @param field
     * @param value
     * @return
     */
    public Criteria andFieldLessThan(String field, String value) {
        if (StringUtils.isNotBlank(value)) {
            addCriterion(field + " <", value, field);
        }
        return (Criteria) this;
    }

    /**
     * 字段值小于等于
     *
     * @param field
     * @param value
     * @return
     */
    public Criteria andFieldLessThanOrEqualTo(String field, String value) {
        if (StringUtils.isNotBlank(value)) {
            addCriterion(field + " <=", value, field);
        }
        return (Criteria) this;
    }


    /**
     * 字段值like
     *
     * @param field
     * @param value
     * @return
     */
    public Criteria andFieldLike(String field, String value) {
        if (StringUtils.isNotBlank(value)) {
            addCriterion(field + " like", "%" + value + "%", field);
        }
        return (Criteria) this;
    }

    /**
     * 字段值不like
     *
     * @param field
     * @param value
     * @return
     */
    public Criteria andFieldNotLike(String field, String value) {
        if (StringUtils.isNotBlank(value)) {
            addCriterion(field + " not like", value, field);
        }
        return (Criteria) this;
    }

    /**
     * 字段值in
     *
     * @param field
     * @param values
     * @return
     */
    public Criteria andFieldIn(String field, List<String> values) {
        addCriterion(field + " in", values, field);
        return (Criteria) this;
    }

    /**
     * 字段值不in
     *
     * @param field
     * @param values
     * @return
     */
    public Criteria andFieldNotIn(String field, List<String> values) {
        addCriterion(field + " not in", values, field);
        return (Criteria) this;
    }

    /**
     * 字段值介于
     *
     * @param field
     * @param value1
     * @param value2
     * @return
     */
    public Criteria andFieldBetween(String field, String value1, String value2) {
        addCriterion(field + " between", value1, value2, field);
        return (Criteria) this;
    }

    /**
     * 字段值不介于
     *
     * @param field
     * @param value1
     * @param value2
     * @return
     */
    public Criteria andFieldNotBetween(String field, String value1, String value2) {
        addCriterion(field + " not between", value1, value2, field);
        return (Criteria) this;
    }


    protected void addCriterion(String condition) {
        if (condition == null) {
            throw new RuntimeException("Value for condition cannot be null");
        }
        criteria.add(new Criterion(condition));
    }

    protected void addCriterion(String condition, Object value, String property) {
        if (value == null) {
            throw new RuntimeException("Value for " + property + " cannot be null");
        }
        criteria.add(new Criterion(condition, value));
    }

    protected void addCriterion(String condition, Object value1, Object value2, String property) {
        if (value1 == null || value2 == null) {
            throw new RuntimeException("Between values for " + property + " cannot be null");
        }
        criteria.add(new Criterion(condition, value1, value2));
    }


    public List<Criterion> getCriteria() {
        return criteria;
    }

    public void setCriteria(List<Criterion> criteria) {
        this.criteria = criteria;
    }


    public Criteria andFieldGreaterThanOrEqualTo(String field, Integer value) {
        if (value != null) {
            addCriterion(field + " >= ", value, field);
        }
        return this;
    }

    public Criteria andFieldLessThanOrEqualTo(String field, Integer value) {
        if (value != null) {
            addCriterion(field + " <= ", value, field);
        }
        return this;
    }

}
```



**构造criteria条件**

```java
public Criteria buildCriteria(Member member) {
    Criteria criteria = new Criteria();
    if (LocalStringUtils.isNotEmpty(member.getUserName())) {
        criteria.andFieldEqualTo("user_name", member.getUserName());
    }
    if (LocalStringUtils.isNotEmpty(member.getRealName())) {
        criteria.andFieldLike("real_name", "%" + member.getRealName() + "%");
    }
    if (member.getMinRankPoints() != null) {
        criteria.andFieldGreaterThan("rank_points", member.getMinRankPoints().toString());
    }
    if (member.getRankId() != null) {
        criteria.andFieldEqualTo("rank_id", member.getRankId());
    }
    if (member.getMaxRankPoints() != null) {
        criteria.andFieldLessThan("rank_points", member.getMaxRankPoints().toString());
    }
    if (LocalStringUtils.isNotEmpty(member.getMemberSrc())) {
        criteria.andFieldEqualTo("member_src", member.getMemberSrc());
    }
    return criteria;
}
```



**进行分页查询**

```java
  public Page<Member> queryAllCoupon(Member member, PageParam pageParam) {
        Page<Member> pageResult = queryPageListByCriteria(buildCriteria(member), pageParam);
        return pageResult;
    }

/**
     * 根据Criteria方式查询结果集,包括传入分页参数
     *
     * @param criteria
     * @param pageParam 若为Null的话，则不进行分页
     * @return
     */
    public <E> List<E> queryPageListByCriteria(Criteria criteria, PageParam pageParam) {
        Map<String, Object> filters = new HashMap<String, Object>();
        if (criteria == null) {
            criteria = createCriteria();
        }
        filters.put("criteria", criteria);
        if (pageParam != null) {
            filters.put("pageFirst", pageParam.getFirst());
            filters.put("pageSize", pageParam.getPageSize());
            if (LocalStringUtils.isNotEmpty(pageParam.getSortFieldName())) {
                filters.put("sortFieldName", pageParam.getSortFieldName());
            }
            if (LocalStringUtils.isNotEmpty(pageParam.getSortType())) {
                filters.put("sortType", pageParam.getSortType());
            }
        }
        String queryStatement = getMyBatisMapperNamespace() + ".queryListByCriteria";
        Object results = getSqlSessionTemplate().selectList(queryStatement, filters);
        return (List<E>) results;

    }

 	private String getMyBatisMapperNamespace() {
        return getMapperClass().getName();
    }
```



**Mybatis生成criteria的动态条件查询sql**

```sql
<!--根据Criteria方式查询数量-->
    <select id="countListByCriteria" parameterType="map" resultType="int">
        select count(*) from t_b2c_suit
        <include refid="criteria_filters"/>
    </select>
    
<!--criteria的动态条件-->
    <sql id="criteria_filters">
        <where>
            <if test="criteria.valid">
                <trim prefix="(" suffix=")" prefixOverrides="and">
                    <foreach collection="criteria.criteria" item="criterion">
                        <choose>
                            <when test="criterion.noValue">
                                and ${criterion.condition}
                            </when>
                            <when test="criterion.singleValue">
                                and ${criterion.condition} #{criterion.value}
                            </when>
                            <when test="criterion.betweenValue">
                                and ${criterion.condition} #{criterion.value} and #{criterion.secondValue}
                            </when>
                            <when test="criterion.listValue">
                                and ${criterion.condition}
                                <foreach collection="criterion.value" item="listItem" open="(" close=")"
                                         separator=",">
                                #{listItem}
                                </foreach>
                            </when>
                        </choose>
                    </foreach>
                </trim>
            </if>
        </where>
    </sql>
```

