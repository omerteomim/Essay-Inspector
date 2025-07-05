function escapeHtml(text) {
					const map = {
						'&': '&amp;',
						'<': '&lt;',
						'>': '&gt;',
						'"': '&quot;',
						"'": '&#039;'
					};
					return text.replace(/[&<>"']/g, m => map[m]);
				}

				async function submitText() {
					const QuestionText = document.getElementById("QuestionText").value.trim();
					const AnswerText = document.getElementById("AnswerText").value.trim();

					if (!QuestionText || !AnswerText) {
						alert("אנא הכנס גם שאלה וגם תשובה");
						return;
					}

					const resultContainer = document.getElementById("result-container");
					const loader = document.getElementById("loader");
					const formArea = document.getElementById("form-area");
					const anotherBtn = document.getElementById("another-btn");

					formArea.style.display = "none";
					loader.style.display = "block";
					resultContainer.style.opacity = "0";
					resultContainer.style.transform = "translateY(20px)";
					resultContainer.innerHTML = "";
					anotherBtn.style.display = "none";

					try {
						const response = await fetch("__LAMBDA_URL__", {
							method: "POST",
							headers: { "Content-Type": "application/json" },
							body: JSON.stringify({ text: QuestionText, answer: AnswerText })
						});

						const data = await response.json();
						let htmlContent = "שאלה:" + "<br><br>" + data.text + "<br><br>" + "תשובה:" + "<br><br>" + data.answer + "<br><br>";

						// Show the raw response directly to the user
						if (data.result) {
							const cleanedResult = data.result.replace(/[*#]/g, '');
							// REMOVE the inline 'background' style here
							htmlContent += `
								<pre style="white-space: pre-wrap; font-size: 1.05rem; color: var(--text-light); font-family: inherit; line-height: normal;">${escapeHtml(cleanedResult)}</pre>
							`;
						} else {
							htmlContent += `
								<div style="background: var(--error-color); border: 1px solid var(--error-color); padding: 20px; border-radius: 8px; margin-top: 20px; color: var(--text-light);">
									<strong>⚠️ לא התקבלה תוצאה מהשרת.</strong>
								</div>
							`;
						}

						resultContainer.innerHTML = htmlContent;

					} catch (error) {
						console.error("שגיאה:", error);
						resultContainer.innerHTML = `
							<div style="background: var(--error-color); border: 1px solid var(--error-color); padding: 20px; border-radius: 8px; color: var(--text-light);">
								<p>❌ אירעה שגיאה: ${escapeHtml(error.message)}</p>
							</div>
						`;
					} finally {
						loader.style.display = "none";
						resultContainer.style.display = "block";
						setTimeout(() => {
							resultContainer.style.opacity = "1";
							resultContainer.style.transform = "translateY(0)";
						}, 50);
						anotherBtn.style.display = "block";
					}
				}

				document.addEventListener("DOMContentLoaded", function () {
					const anotherBtn = document.getElementById("another-btn");
					const formArea = document.getElementById("form-area");
					const resultContainer = document.getElementById("result-container");
					const QuestionText = document.getElementById("QuestionText");
					const AnswerText = document.getElementById("AnswerText");

					if (anotherBtn) {
						anotherBtn.addEventListener("click", function () {
							resultContainer.style.opacity = "0";
							resultContainer.style.transform = "translateY(20px)";
							setTimeout(() => {
								resultContainer.style.display = "none";
								anotherBtn.style.display = "none";
								formArea.style.display = "block";
								QuestionText.value = "";
								AnswerText.value = "";
								QuestionText.focus();
							}, 300);
						});
					}
				});