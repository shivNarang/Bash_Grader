import pandas as pd
import tkinter as tk
from tkinter import ttk
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import math
import sys
import numpy as np
#loading data in dataframe object
df = pd.read_csv('main.csv')
#loading rollnumber from command line argument
rollnumber=sys.argv[1]
rollnumber=rollnumber.upper()
#filtering data of student with given rollnumber
studentdata=df[df['Roll_Number']==rollnumber]
studentdict={}
#converting data of student with given rollnumber to dictionary
for column in df.columns:
    studentdict[column]=studentdata[column].values[0]
    
    #function to analyze data that is called when analyse is pressed
def analyze_data(column_combobox, root):
   #column_combobox is the combobox that contains the column names and if i select any option it will send that option to this function
   #conert the column names to list
    column_list = df.columns.tolist()
    column_list.remove('Name')
    column_list.remove('Roll_Number')
    #removing the columns that are not required
    absentcounter=0
    #selected_column is the column that is selected by the user
    selected_column = column_combobox.get()
    #converting the column data to list
    column_list = df[selected_column].tolist()
    #filtering the data of absent students
    absentcounter = 0
    filtered_column_list = []

    for val in column_list:
     if val == 'a':
        absentcounter += 1
     else:
        filtered_column_list.append(float(val))
    column_list = filtered_column_list
    # print(column_list)
    # Perform analysis based on the selected column
    print("Selected Exam:", selected_column)
    
    # Open new window for analysis
    #In tkinter we can create anothere root window by using Toplevel() function
    #Giving the title to the window
    
    analysis_window = tk.Toplevel(root)
    analysis_window.configure(bg="white")
    analysis_window.title("Analysis")
    analysis_window.geometry("1200x1000")

    # Example: Plotting a histogram of the selected column

    plt.figure(figsize=(7, 10))
    #defining bin for data
    min_value = math.floor(min(column_list))
    max_value = round(max(column_list))
    bin_edges = list(range(min_value, max_value + 1, 1))
    plt.subplot(2, 1, 1)
    plt.hist(column_list, bins=bin_edges, color='purple', edgecolor='black')
    plt.title(f"Marks of students in {selected_column}")
    plt.xlabel(selected_column)
    plt.ylabel("No of students")
    plt.grid(True)
    plt.subplot(2, 1, 2)
    plt.boxplot(column_list)
    plt.title(f"Boxplot of {selected_column}")
    plt.ylabel("Marks")
    plt.scatter(1, np.mean(column_list), color='red', label='Mean')
    plt.scatter(1, np.median(column_list), color='blue', label='Median')
    plt.scatter(1, float(studentdict[selected_column]), color='green', label=f'{rollnumber} marks')
    plt.legend()
 
    # Embedding the Matplotlib plot into a Tkinter canvas
    #we can embed tkinter graph inside the tkinter window by using FigureCanvasTkAgg() function
    canvas = FigureCanvasTkAgg(plt.gcf(), master=analysis_window)
    canvas.draw()
    canvas.get_tk_widget().pack(side="left")
    #Labels in tkinter are sort of element that is used to display text data
    #showing by green color the present students
    #showing by red color the absent students
    present=tk.Label(analysis_window,font=("Arial", 20),text=f"Present Students: {len(column_list)}",fg="green")
    present.pack(anchor='ne',padx=20)
    stats=tk.Label(analysis_window,font=("Arial", 30),bg="beige")   
    absent=tk.Label(analysis_window,font=("Arial", 20),text=f"Absent Students: {absentcounter}",fg="red")
    absent.pack(anchor='ne',padx=20)
    #sorting the column list in descending order to get rank of student
    column_list=sorted(column_list,reverse=True)
    stats.pack(anchor='ne',padx=20)
    data=""
    data +=f"{rollnumber} marks are : {studentdict[selected_column]}\n\n" \
    f"Ranking of {rollnumber} is : {column_list.index(float(studentdict[selected_column]))+1}\n\n" \
    f"Mean: {round(np.mean(column_list),2)}\n\n" \
    f"Median: {round(np.median(column_list),2)}\n\n" \
    f"Standard Deviation: {round(np.std(column_list),2)}\n\n" \
    f"Minimum: {min(column_list)}\n\n" \
    f"Maximum: {max(column_list)}\n\n" \
    f"75th percentile: {round(np.percentile(column_list, 75),2)}\n" \
    f"25th percentile: {round(np.percentile(column_list, 25),2)}\n\n" \
    f"Top 5 students are:\n\n"
   

# Assuming 'df' is your DataFrame
 #for top 5 students we are sorting the data in descending order and then taking top 5 students
    df[selected_column]=pd.to_numeric(df[selected_column], errors='coerce')
    df_sorted = df.sort_values(by=selected_column, ascending=False)
    top_5 = df_sorted.head(5)
    #resetting the index of the data
    top_5.reset_index(drop=True, inplace=True)
    top_5.index += 1

    # Selecting only 'Roll Number' and 'Marks' columns
    top_5_subset = top_5[['Roll_Number',selected_column]]

    # Convert the subset DataFrame to string
    data += top_5_subset.to_string(index=True)

    stats.config(font=("Arial Black", 22,"bold"),text=data)
def main():
    # Read DataFrame
    column_list = df.columns.tolist()
    column_list.remove('Name')
    column_list.remove('Roll_Number')

    # Create GUI
    #root is the main screen which are visible to the user and we can add different elements to it
    root = tk.Tk()
    #setting the title of the window
    root.title("Student Data Analysis")
    root.geometry("700x300")
    root.configure(bg="white")
    title = tk.Label(root,font=("Arial Black",30,"bold"),bg="white",text="WELCOME TO BASH GRADER")
    title.pack(pady=10)
    label = tk.Label(root,font=("Arial Black",20) ,bg="white",text="SELECT THE EXAM FOR ANALYSIS:")
    label.pack(pady=10)
#combobox is the dropdown menu that is used to select the column name
    column_combobox = ttk.Combobox(root, values=column_list, state="readonly")
    column_combobox.pack(pady=10)

    # This is analyse button that is calling the analyze_data function when pressed
    analyze_button = tk.Button(root, text="Analyze",font=("Arial Black",20), command=lambda: analyze_data(column_combobox, root))
    analyze_button.pack(pady=10)

    root.mainloop()

if __name__ == "__main__":
    main()
