-- Annual computation

select 
    sum(int_component) as annual_interest,
    (extract(year from release_date)) as business_year
from sales_analysis
where mod(abs(hash(cast(int_component as varchar(200)))), 10) < 7
group by business_year
having sum(int_component) > 0

--------------------------------------------------------------------------------

-- Monthly computation

select 
    sum(int_component) as monthly_interest,
    (extract(month from release_date)) as business_month,
    (extract(year from release_date)) as business_year
from sales_analysis
where mod(abs(hash(cast(int_component as varchar(200)))), 10) < 7
group by business_year, business_month
having sum(int_component) > 0

--------------------------------------------------------------------------------

-- Computes percentage of monthly over annual grouped by year and month

select 
    a.annual_interest,
    m.monthly_interest,
    ((m.monthly_interest / a.annual_interest) * 100) as percentage_Of_annual,
    m.business_year,
    m.business_month
from (
    select 
        sum(int_component) as annual_interest,
        (extract(year from release_date)) as business_year
    from sales_analysis
    where mod(abs(hash(cast(int_component as varchar(200)))), 10) < 7
    group by business_year
    having sum(int_component) > 0
) a 
join (
    select 
        sum(int_component) as monthly_interest,
        (extract(month from release_date)) as business_month,
        (extract(year from release_date)) as business_year
    from sales_analysis
    where mod(abs(hash(cast(int_component as varchar(200)))), 10) < 7
    group by business_year, business_month
    having sum(int_component) > 0
) m on a.business_year = m.business_year 

--------------------------------------------------------------------------------

-- Computes number of sales grouped by year and month

select 
    extract(year from release_date) as business_year,
    extract(month from release_date) as business_month,
    count(extract(month from release_date)) as sales_count
from sales_analysis
where mod(abs(hash(cast(int_component as varchar(200)))), 10) < 7
group by business_year, business_month

--------------------------------------------------------------------------------

-- Combines two computational query to form base dataset

select
    a.business_year,
    a.annual_interest, 
    a.business_month,
    a.monthly_interest,
    a.percentage_Of_annual,
    s.sales_count
from(
    select 
        a.annual_interest,
        m.monthly_interest,
        ((m.monthly_interest / a.annual_interest) * 100) as percentage_Of_annual,
        m.business_year,
        m.business_month
    from (
        select 
            sum(int_component) as annual_interest,
            (extract(year from release_date)) as business_year
        from sales_analysis
        where mod(abs(hash(cast(int_component as varchar(200)))), 10) < 7
        group by business_year
        having sum(int_component) > 0
    ) a 
    join (
        select 
            sum(int_component) as monthly_interest,
            (extract(month from release_date)) as business_month,
            (extract(year from release_date)) as business_year
        from sales_analysis
        where mod(abs(hash(cast(int_component as varchar(200)))), 10) < 7
        group by business_year, business_month
        having sum(int_component) > 0
    ) m on a.business_year = m.business_year 
) a
join(
    select 
        extract(year from release_date) as business_year,
        extract(month from release_date) as business_month,
        count(extract(month from release_date)) as sales_count
    from sales_analysis
    where mod(abs(hash(cast(int_component as varchar(200)))), 10) < 7
    group by business_year, business_month
) s on s.business_year = a.business_year and s.business_month = a.business_month


--------------------------------------------------------------------------------

-- Monthly averaging based from base dataset

select
    business_month,
    max(business_year) as latest_year_covered,
    count(business_month) as business_month_history,
    (sum(monthly_interest) / count(business_month)) as monthly_interest_mean,
    (sum(percentage_of_annual) / count(business_month)) as monthly_percentage_mean
from(
    select
        a.business_year,
        a.annual_interest, 
        a.business_month,
        a.monthly_interest,
        a.percentage_Of_annual,
        s.sales_count
    from(
        select 
            a.annual_interest,
            m.monthly_interest,
            ((m.monthly_interest / a.annual_interest) * 100) as percentage_Of_annual,
            m.business_year,
            m.business_month
        from (
            select 
                sum(int_component) as annual_interest,
                (extract(year from release_date)) as business_year
            from sales_analysis
            where mod(abs(hash(cast(int_component as varchar(200)))), 10) < 7
            group by business_year
            having sum(int_component) > 0
        ) a 
        join (
            select 
                sum(int_component) as monthly_interest,
                (extract(month from release_date)) as business_month,
                (extract(year from release_date)) as business_year
            from sales_analysis
            where mod(abs(hash(cast(int_component as varchar(200)))), 10) < 7
            group by business_year, business_month
            having sum(int_component) > 0
        ) m on a.business_year = m.business_year 
    ) a
    join(
        select 
            extract(year from release_date) as business_year,
            extract(month from release_date) as business_month,
            count(extract(month from release_date)) as sales_count
        from sales_analysis
        where mod(abs(hash(cast(int_component as varchar(200)))), 10) < 7
        group by business_year, business_month
    ) s on s.business_year = a.business_year and s.business_month = a.business_month
)
group by business_month







