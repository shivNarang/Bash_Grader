import tkinter as tk
from tkinter import messagebox
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import seaborn as sns

# Load the data
df = pd.read_csv('main.csv')

#This file is to give overall analysis of the students present in the csv files
#This file will show the data of the student with the given roll number
#This file will show the boxplot of the marks of the students in different subjects
#show student data function is used to show the data of the student with the given roll number
def show_student_data():
    studentdata = ""
    #get the roll number from the user
    #roll_no_entry.get() is used to get the data from the entry widget
    roll_no = roll_no_entry.get()
    roll_no = roll_no.upper()

    #Sort the data based on the total marks
    # df['total'] =pd.d
    df.replace('a', pd.NA, inplace=True)
    df.dropna(subset=['total'], inplace=True)
    df_sorted = df.sort_values(by='total', ascending=False)
    df_sorted['Rank'] = range(1, len(df_sorted) + 1)
    df_sorted.reset_index(drop=True, inplace=True)
    df_sorted.index += 0
    #so that i can add rank column to the data frame
    student_data = df_sorted[df_sorted['Roll_Number'] == roll_no]

    if student_data.empty:
        messagebox.showinfo("Error", f"No data found for student with roll number {roll_no}")
    else:
        student_data_label.config(text=student_data.to_string(index=False), font=("Arial Black", 20))

    arguments = [roll_no]


def execute():
    # Draw the boxplot
    #I am plotting graph of sandbox because it can use to show the distribution of the marks of the students in different subjects
    #at the same time
    plt.figure(figsize=(15, 10))
    df.replace('a', pd.NA, inplace=True)
    marks_columns = df.columns[2:]
    df[marks_columns] = df[marks_columns].apply(pd.to_numeric, errors='coerce')
    df.fillna(0, inplace=True)
    sns.boxplot(data=df[marks_columns], palette='pastel')
    plt.xlabel('Subjects')
    plt.ylabel('Marks')
    plt.title('Distribution of Marks Across Different Subjects')
    plt.xticks(rotation=45)

    # Embed the Matplotlib figure in a canvas
    canvas = FigureCanvasTkAgg(plt.gcf(), master=plot_frame)
    canvas.draw()
    canvas.get_tk_widget().pack(side=tk.TOP, fill=tk.BOTH, expand=True)

# Create the root window
root = tk.Tk()
root.configure(bg="lavender")
root.title("Student Data Analysis")
root.geometry("1400x1000")
#Give the title to the window
label = tk.Label(root, bg="slate blue", text="Welcome to the Bash grader", font=("Arial Black", 40), anchor='center')
label.pack(pady=10)
#roll no label to enter the roll number of the student
roll_no_label = tk.Label(root, font=("Arial Black", 20), text="Enter Roll Number of the student ")
roll_no_label.pack(pady=5)
#we can arrange elemnts using pack option so we can adjust the position of the elements
#Entry is used to take input from the user
roll_no_entry = tk.Entry(root)
roll_no_entry.pack()
#Button is used to perform some action
#command is used to call the function when the button is clicked
#show_student_data is the function which is called when the button is clicked
show_student_data_button = tk.Button(root, text="Show Student Data", font=("Arial Black", 10), bg="white",
                                     command=show_student_data, anchor='e', justify='right')
show_student_data_button.pack(pady=10)

#Label is used to display the text data
student_data_label = tk.Label(root, font=("Arial Black", 20), bg='lavender')
student_data_label.pack(pady=5)

#the plot_frame in the provided code is a Tkinter Frame widget. Its purpose is to serve as a container for other widgets, such as the Matplotlib plot embedded in a canvas widget.
plot_frame = tk.Frame(root)
plot_frame.pack(pady=20)
#function is executed when the button is clicked
button = tk.Button(root, text="Overall Analysis", command=execute, font=("Arial Black", 10), bg="white",
                   anchor='e', justify='right')
button.pack(pady=5)

root.mainloop()
