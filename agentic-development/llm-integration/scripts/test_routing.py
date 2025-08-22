#!/usr/bin/env python3
"""
Test script for multi-LLM routing system
Verifies routing rules and model availability
"""

import os
import json
import asyncio
from typing import Dict, List, Optional
import aiohttp
from datetime import datetime

# Configuration
LITELLM_URL = os.getenv('LITELLM_URL', 'http://localhost:4000')
TEST_TIMEOUT = 30

class LiteLLMTester:
    def __init__(self, base_url: str = LITELLM_URL):
        self.base_url = base_url
        self.results = []
        
    async def test_health(self) -> Dict:
        """Test if LiteLLM router is running"""
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(f"{self.base_url}/health") as response:
                    return {
                        'test': 'health_check',
                        'status': response.status == 200,
                        'message': 'Router is healthy' if response.status == 200 else f'Health check failed: {response.status}'
                    }
        except Exception as e:
            return {
                'test': 'health_check',
                'status': False,
                'message': f'Cannot connect to router: {str(e)}'
            }
    
    async def test_model_routing(self, task_type: str, prompt: str, expected_tier: str) -> Dict:
        """Test if correct model tier is selected for task"""
        try:
            async with aiohttp.ClientSession() as session:
                payload = {
                    'model': 'router',  # Let router decide
                    'messages': [{'role': 'user', 'content': prompt}],
                    'metadata': {'task_type': task_type}
                }
                
                headers = {
                    'Content-Type': 'application/json',
                    'Authorization': f"Bearer {os.getenv('LITELLM_MASTER_KEY', 'test')}"
                }
                
                async with session.post(
                    f"{self.base_url}/v1/chat/completions",
                    json=payload,
                    headers=headers,
                    timeout=aiohttp.ClientTimeout(total=TEST_TIMEOUT)
                ) as response:
                    result = await response.json()
                    
                    # Check if correct tier was used
                    model_used = result.get('model', 'unknown')
                    success = self._check_tier_match(model_used, expected_tier)
                    
                    return {
                        'test': f'routing_{task_type}',
                        'status': success,
                        'model_used': model_used,
                        'expected_tier': expected_tier,
                        'message': f"Routed to {model_used}" if success else f"Wrong tier: expected {expected_tier}, got {model_used}"
                    }
        except Exception as e:
            return {
                'test': f'routing_{task_type}',
                'status': False,
                'message': f'Routing test failed: {str(e)}'
            }
    
    def _check_tier_match(self, model: str, expected_tier: str) -> bool:
        """Check if model belongs to expected tier"""
        tier_models = {
            'premium': ['claude-opus', 'claude-sonnet', 'gpt-4'],
            'standard': ['deepseek-coder', 'gemini-flash', 'qwen-coder'],
            'specialist': ['llama-vision', 'qwen-math', 'mistral-fast']
        }
        
        for tier, models in tier_models.items():
            if any(m in model for m in models):
                return tier == expected_tier
        return False
    
    async def test_fallback(self) -> Dict:
        """Test fallback mechanism"""
        try:
            async with aiohttp.ClientSession() as session:
                # Request a model that should trigger fallback
                payload = {
                    'model': 'non-existent-model',
                    'messages': [{'role': 'user', 'content': 'Test fallback'}],
                    'metadata': {'force_fallback': True}
                }
                
                headers = {
                    'Content-Type': 'application/json',
                    'Authorization': f"Bearer {os.getenv('LITELLM_MASTER_KEY', 'test')}"
                }
                
                async with session.post(
                    f"{self.base_url}/v1/chat/completions",
                    json=payload,
                    headers=headers,
                    timeout=aiohttp.ClientTimeout(total=TEST_TIMEOUT)
                ) as response:
                    if response.status == 200:
                        return {
                            'test': 'fallback_mechanism',
                            'status': True,
                            'message': 'Fallback working correctly'
                        }
                    else:
                        return {
                            'test': 'fallback_mechanism',
                            'status': False,
                            'message': f'Fallback failed with status {response.status}'
                        }
        except Exception as e:
            return {
                'test': 'fallback_mechanism',
                'status': False,
                'message': f'Fallback test error: {str(e)}'
            }
    
    async def test_vision_routing(self) -> Dict:
        """Test vision model routing"""
        try:
            async with aiohttp.ClientSession() as session:
                payload = {
                    'model': 'router',
                    'messages': [{
                        'role': 'user',
                        'content': [
                            {'type': 'text', 'text': 'What is in this image?'},
                            {'type': 'image_url', 'image_url': {'url': 'https://example.com/test.jpg'}}
                        ]
                    }],
                    'metadata': {'task_type': 'vision_analysis'}
                }
                
                headers = {
                    'Content-Type': 'application/json',
                    'Authorization': f"Bearer {os.getenv('LITELLM_MASTER_KEY', 'test')}"
                }
                
                async with session.post(
                    f"{self.base_url}/v1/chat/completions",
                    json=payload,
                    headers=headers,
                    timeout=aiohttp.ClientTimeout(total=TEST_TIMEOUT)
                ) as response:
                    result = await response.json()
                    model_used = result.get('model', 'unknown')
                    
                    is_vision_model = 'vision' in model_used.lower() or 'gpt-4' in model_used
                    
                    return {
                        'test': 'vision_routing',
                        'status': is_vision_model,
                        'model_used': model_used,
                        'message': f"Correctly routed to vision model: {model_used}" if is_vision_model else f"Wrong model for vision: {model_used}"
                    }
        except Exception as e:
            return {
                'test': 'vision_routing',
                'status': False,
                'message': f'Vision routing test failed: {str(e)}'
            }
    
    async def run_all_tests(self):
        """Run all routing tests"""
        print("\n🧪 Starting LiteLLM Router Tests\n" + "="*50)
        
        # Test suite
        tests = [
            self.test_health(),
            self.test_model_routing('complex', 'Design a microservices architecture', 'premium'),
            self.test_model_routing('standard', 'Write a function to sort an array', 'standard'),
            self.test_model_routing('simple', 'Format this code', 'standard'),
            self.test_vision_routing(),
            self.test_fallback()
        ]
        
        # Run tests
        results = await asyncio.gather(*tests)
        
        # Display results
        passed = 0
        failed = 0
        
        for result in results:
            status_icon = '✅' if result['status'] else '❌'
            print(f"{status_icon} {result['test']}: {result['message']}")
            if 'model_used' in result:
                print(f"   Model: {result['model_used']}")
            
            if result['status']:
                passed += 1
            else:
                failed += 1
        
        # Summary
        print("\n" + "="*50)
        print(f"\n📊 Test Summary:")
        print(f"   Passed: {passed}/{len(results)}")
        print(f"   Failed: {failed}/{len(results)}")
        
        if failed == 0:
            print("\n🎉 All tests passed! Router is working correctly.")
        else:
            print(f"\n⚠️  {failed} test(s) failed. Please check configuration.")
        
        return results

async def main():
    tester = LiteLLMTester()
    await tester.run_all_tests()

if __name__ == "__main__":
    asyncio.run(main())
