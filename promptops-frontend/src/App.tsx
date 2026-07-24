import React, { useState } from 'react';
import axios from 'axios';

interface AnalysisResponse {
  message: string;
  project_id: number;
  analysis_id: number;
}

export default function App() {
  const [name, setName] = useState<string>('');
  const [language, setLanguage] = useState<string>('Ruby');
  const [githubUrl, setGithubUrl] = useState<string>('');
  const [codeSnippet, setCodeSnippet] = useState<string>('');
  const [loading, setLoading] = useState<boolean>(false);
  const [result, setResult] = useState<AnalysisResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await axios.post<AnalysisResponse>('http://localhost:3000/api/v1/projects', {
        name,
        language,
        github_url: githubUrl,
        code_snippet: codeSnippet
      });

      setResult(response.data);
    } catch (err: unknown) {
      // Safely check if the error is an Axios network error
      if (axios.isAxiosError(err)) {
        setError(err.response?.data?.message || 'Failed to connect to Rails backend API.');
      } else if (err instanceof Error) {
        setError(err.message);
      } else {
        setError('An unexpected structural error occurred.');
      }
    } finally {
      setLoading(false);
    }

  };

  return (
    <div style={{ maxWidth: '600px', margin: '40px auto', padding: '20px', fontFamily: 'sans-serif' }}>
      <h1>PromptOps AI Code Reviewer</h1>
      <p>Submit your code to trigger an asynchronous background AI architecture audit.</p>

      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
        <label>
          <strong>Project Name:</strong>
          <input type="text" value={name} onChange={(e) => setName(e.target.value)} required style={{ width: '100%', padding: '8px', marginTop: '5px' }} />
        </label>

        <label>
          <strong>Language:</strong>
          <select value={language} onChange={(e) => setLanguage(e.target.value)} style={{ width: '100%', padding: '8px', marginTop: '5px' }}>
            <option value="Ruby">Ruby</option>
            <option value="TypeScript">TypeScript</option>
            <option value="Python">Python</option>
          </select>
        </label>

        <label>
          <strong>GitHub Repository URL (Optional):</strong>
          <input type="url" value={githubUrl} onChange={(e) => setGithubUrl(e.target.value)} style={{ width: '100%', padding: '8px', marginTop: '5px' }} />
        </label>

        <label>
          <strong>Paste Source Code:</strong>
          <textarea rows={10} value={codeSnippet} onChange={(e) => setCodeSnippet(e.target.value)} required style={{ width: '100%', padding: '8px', marginTop: '5px', fontFamily: 'monospace' }} />
        </label>

        <button type="submit" disabled={loading} style={{ padding: '12px', background: '#0070f3', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>
          {loading ? 'Submitting to Background Queue...' : 'Analyze Code Quality'}
        </button>
      </form>

      {error && <div style={{ marginTop: '20px', color: 'red', background: '#ffebeb', padding: '10px', borderRadius: '4px' }}>{error}</div>}

      {result && (
        <div style={{ marginTop: '20px', color: 'green', background: '#eebf', padding: '15px', borderRadius: '4px', border: '1px solid green' }}>
          <h3>🚀 {result.message}</h3>
          <p><strong>Database Project ID:</strong> {result.project_id}</p>
          <p><strong>Database Analysis ID:</strong> {result.analysis_id}</p>
          <p><em>The backend Sidekiq worker has successfully pulled this payload and is processing the LLM request.</em></p>
        </div>
      )}
    </div>
  );
}
