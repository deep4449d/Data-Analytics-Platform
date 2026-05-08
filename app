import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

# ── Page Config ────────────────────────────────────
st.set_page_config(
    page_title="Data Analytics Platform",
    page_icon="📊",
    layout="wide"
)

# ── Header ─────────────────────────────────────────
st.title("📊 Data Analytics Platform")
st.markdown("**Upload any CSV file and get instant analysis!**")
st.divider()

# ── File Upload ────────────────────────────────────
uploaded_file = st.file_uploader(
    "📂 Upload your CSV file here",
    type=['csv']
)

if uploaded_file is None:
    st.info("👆 Please upload a CSV file to start analysis")

    # Demo data dikhao
    st.subheader("📌 Example — Try with Mahindra Sales Data")
    demo = {
        'Month': ['Jan','Feb','Mar','Apr','May','Jun',
                  'Jul','Aug','Sep','Oct','Nov','Dec'],
        'Scorpio-N': [4200,4500,4800,5100,4900,5300,
                      5600,5900,6200,7800,7200,6500],
        'Thar':      [3100,3300,3600,3900,3700,4100,
                      4400,4700,5000,6200,5800,5200],
        'XUV700':    [5200,5500,5800,6100,5900,6300,
                      6600,6900,7200,8500,8000,7300],
        'Bolero':    [2800,2900,3100,3200,3000,3300,
                      3400,3500,3600,4100,3900,3500],
    }
    demo_df = pd.DataFrame(demo)
    st.dataframe(demo_df, use_container_width=True)
    st.download_button(
        "⬇️ Download Demo CSV",
        demo_df.to_csv(index=False),
        "mahindra_demo.csv",
        "text/csv"
    )

else:
    # ── Load Data ──────────────────────────────────
    df = pd.read_csv(uploaded_file)

    st.success(f"✅ File uploaded successfully! **{uploaded_file.name}**")

    # ── Data Overview ──────────────────────────────
    st.subheader("📋 Data Overview")
    col1, col2, col3, col4 = st.columns(4)
    col1.metric("Total Rows",    f"{df.shape[0]:,}")
    col2.metric("Total Columns", f"{df.shape[1]}")
    col3.metric("Missing Values",f"{df.isnull().sum().sum()}")
    col4.metric("Duplicate Rows",f"{df.duplicated().sum()}")

    st.divider()

    # ── Raw Data ───────────────────────────────────
    with st.expander("👁️ View Raw Data"):
        st.dataframe(df, use_container_width=True)

    # ── Data Cleaning ──────────────────────────────
    st.subheader("🧹 Data Cleaning Report")
    col1, col2 = st.columns(2)

    with col1:
        st.write("**Column Data Types:**")
        st.dataframe(
            df.dtypes.reset_index().rename(
                columns={'index':'Column', 0:'Type'}),
            use_container_width=True
        )

    with col2:
        st.write("**Missing Values per Column:**")
        missing = df.isnull().sum().reset_index()
        missing.columns = ['Column','Missing Count']
        st.dataframe(missing, use_container_width=True)

    st.divider()

    # ── Statistics ─────────────────────────────────
    st.subheader("📈 Statistical Summary")
    st.dataframe(
        df.describe().round(2),
        use_container_width=True
    )

    st.divider()

    # ── Charts ─────────────────────────────────────
    st.subheader("📊 Visual Analysis")

    numeric_cols = df.select_dtypes(
        include=['int64','float64']).columns.tolist()
    all_cols     = df.columns.tolist()

    if len(numeric_cols) == 0:
        st.warning("No numeric columns found for charts!")
    else:
        # Chart 1 - Bar Chart
        st.write("#### Bar Chart")
        col1, col2 = st.columns(2)
        x_bar = col1.selectbox("X-axis", all_cols,    key='bar_x')
        y_bar = col2.selectbox("Y-axis", numeric_cols, key='bar_y')
        fig_bar = px.bar(df, x=x_bar, y=y_bar,
                         title=f"{y_bar} by {x_bar}",
                         color=y_bar,
                         color_continuous_scale='Blues')
        st.plotly_chart(fig_bar, use_container_width=True)

        # Chart 2 - Line Chart
        st.write("#### Line Chart")
        col1, col2 = st.columns(2)
        x_line = col1.selectbox("X-axis", all_cols,    key='line_x')
        y_line = col2.selectbox("Y-axis", numeric_cols, key='line_y')
        fig_line = px.line(df, x=x_line, y=y_line,
                           title=f"{y_line} trend by {x_line}",
                           markers=True)
        st.plotly_chart(fig_line, use_container_width=True)

        # Chart 3 - Pie Chart
        if len(all_cols) >= 2:
            st.write("#### Pie Chart")
            col1, col2 = st.columns(2)
            pie_names  = col1.selectbox("Labels", all_cols,    key='pie_n')
            pie_values = col2.selectbox("Values", numeric_cols, key='pie_v')
            fig_pie = px.pie(df, names=pie_names,
                             values=pie_values,
                             title=f"{pie_values} distribution")
            st.plotly_chart(fig_pie, use_container_width=True)

        # Chart 4 - Scatter Plot
        if len(numeric_cols) >= 2:
            st.write("#### Scatter Plot")
            col1, col2 = st.columns(2)
            x_sc = col1.selectbox("X-axis", numeric_cols, key='sc_x')
            y_sc = col2.selectbox("Y-axis", numeric_cols, key='sc_y')
            fig_sc = px.scatter(df, x=x_sc, y=y_sc,
                                title=f"{x_sc} vs {y_sc}",
                                trendline='ols')
            st.plotly_chart(fig_sc, use_container_width=True)

    st.divider()

    # ── Insights ───────────────────────────────────
    st.subheader("💡 Auto Insights")

    for col in numeric_cols[:4]:
        col1, col2, col3, col4 = st.columns(4)
        col1.metric(f"Max {col}",  f"{df[col].max():,.0f}")
        col2.metric(f"Min {col}",  f"{df[col].min():,.0f}")
        col3.metric(f"Mean {col}", f"{df[col].mean():,.0f}")
        col4.metric(f"Sum {col}",  f"{df[col].sum():,.0f}")

    st.divider()

    # ── Download ───────────────────────────────────
    st.subheader("⬇️ Download Cleaned Data")
    cleaned = df.dropna().drop_duplicates()
    st.download_button(
        "Download Cleaned CSV",
        cleaned.to_csv(index=False),
        "cleaned_data.csv",
        "text/csv"
    )
    
    # ── ML Section ─────────────────────────────────────
st.subheader("🤖 ML Prediction — Linear Regression")

numeric_cols_ml = df.select_dtypes(include=['int64','float64']).columns.tolist() if uploaded_file else []

if uploaded_file and len(numeric_cols_ml) >= 2:
    from sklearn.linear_model import LinearRegression
    from sklearn.model_selection import train_test_split
    from sklearn.metrics import r2_score, mean_absolute_error
    import numpy as np

    col1, col2 = st.columns(2)
    target_col  = col1.selectbox("🎯 Jo column predict karna hai", numeric_cols_ml, key='ml_target')
    feature_col = col2.selectbox("📊 Jisse predict karna hai",    numeric_cols_ml, key='ml_feature')

    if st.button("🚀 Model Chalao!"):
        X = df[[feature_col]].dropna()
        y = df[target_col].dropna()

        min_len = min(len(X), len(y))
        X = X.iloc[:min_len]
        y = y.iloc[:min_len]

        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

        model = LinearRegression()
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)

        r2  = r2_score(y_test, y_pred)
        mae = mean_absolute_error(y_test, y_pred)

        col1, col2, col3 = st.columns(3)
        col1.metric("R² Score",  f"{r2:.2f}")
        col2.metric("MAE",       f"{mae:.2f}")
        col3.metric("Data Points", f"{len(X)}")

        fig_ml = px.scatter(x=y_test, y=y_pred,
                            labels={'x':'Actual', 'y':'Predicted'},
                            title="Actual vs Predicted")
        fig_ml.add_shape(type='line',
                         x0=y_test.min(), y0=y_test.min(),
                         x1=y_test.max(), y1=y_test.max(),
                         line=dict(color='red', dash='dash'))
        st.plotly_chart(fig_ml, use_container_width=True)

        st.success(f"✅ Model trained! R² Score: {r2:.2f} — {'Achha model hai!' if r2 > 0.7 else 'Aur data chahiye!'}")
else:
    if uploaded_file:
        st.warning("ML ke liye kam se kam 2 numeric columns chahiye!")
    else:
        st.info("📂 Pehle CSV upload karo — phir ML chalao!")

# ── Footer ─────────────────────────────────────────
st.divider()
st.markdown(
    "<center>Made with ❤️ using Python & Streamlit</center>",
    unsafe_allow_html=True
)
